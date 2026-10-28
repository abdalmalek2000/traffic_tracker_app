package com.am.traffic_tracker_app

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import android.net.NetworkRequest
import android.net.VpnService
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.ParcelFileDescriptor
import io.flutter.plugin.common.EventChannel
import java.io.File
import java.io.FileInputStream
import java.io.FileOutputStream
import java.io.IOException
import java.net.InetAddress
import java.net.InetSocketAddress
import java.nio.ByteBuffer
import java.nio.ByteOrder

class TrafficVpnService : VpnService() {

    private var vpnInterface: ParcelFileDescriptor? = null
    private var tunOutputStream: FileOutputStream? = null
    private val tunWriteLock = Any()
    private var forwarder: VpnForwarder? = null
    private var isThreadRunning = false
    private var vpnThread: Thread? = null
    private var pcapOutputStream: FileOutputStream? = null
    private var networkCallback: ConnectivityManager.NetworkCallback? = null

    companion object {
        const val ACTION_START = "com.am.traffic_tracker_app.START"
        const val ACTION_STOP = "com.am.traffic_tracker_app.STOP"
        const val EXTRA_ALLOWED_PACKAGES = "allowed_packages"

        var isRunning = false
            private set

        var eventSink: EventChannel.EventSink? = null
        var pcapFilePath: String? = null
        var packetCount = 0L
        var totalBytesCaptured = 0L
        val allowedPackageSet: HashSet<String> = hashSetOf()

        private val mainHandler = Handler(Looper.getMainLooper())

        fun updateAllowedPackages(packages: List<String>?) {
            synchronized(allowedPackageSet) {
                allowedPackageSet.clear()
                if (!packages.isNullOrEmpty()) {
                    allowedPackageSet.addAll(packages)
                }
            }
        }

        fun sendEvent(data: Map<String, Any?>) {
            mainHandler.post {
                try {
                    eventSink?.success(data)
                } catch (_: Exception) {}
            }
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val action = intent?.action
        if (action == ACTION_STOP) {
            stopVpn()
            return START_NOT_STICKY
        }

        // Verify device has active Wi-Fi or Mobile Data before starting VPN
        if (!NetworkUtils.isNetworkConnected(this)) {
            stopVpn()
            return START_NOT_STICKY
        }

        val allowedList = intent?.getStringArrayListExtra(EXTRA_ALLOWED_PACKAGES)
        updateAllowedPackages(allowedList)
        startVpn(allowedList)
        return START_STICKY
    }

    fun writeToTun(packet: ByteArray) {
        synchronized(tunWriteLock) {
            try {
                tunOutputStream?.write(packet)
                tunOutputStream?.flush()
            } catch (_: Exception) {}
        }
    }

    private fun getSystemDnsServers(): List<String> {
        val dnsList = mutableListOf<String>()
        try {
            val cm = getSystemService(Context.CONNECTIVITY_SERVICE) as? ConnectivityManager
            if (cm != null) {
                val activeNetwork = cm.activeNetwork
                if (activeNetwork != null) {
                    val linkProperties = cm.getLinkProperties(activeNetwork)
                    if (linkProperties != null) {
                        for (dns in linkProperties.dnsServers) {
                            if (dns is java.net.Inet4Address) {
                                val host = dns.hostAddress
                                if (!host.isNullOrEmpty()) {
                                    dnsList.add(host)
                                }
                            }
                        }
                    }
                }
            }
        } catch (_: Exception) {}
        return if (dnsList.isNotEmpty()) dnsList else listOf("8.8.8.8", "1.1.1.1")
    }

    private fun registerNetworkCallback() {
        try {
            val cm = getSystemService(Context.CONNECTIVITY_SERVICE) as? ConnectivityManager ?: return
            val request = NetworkRequest.Builder()
                .addCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET)
                .build()

            networkCallback = object : ConnectivityManager.NetworkCallback() {
                override fun onLost(network: android.net.Network) {
                    super.onLost(network)
                    if (!NetworkUtils.isNetworkConnected(this@TrafficVpnService)) {
                        stopVpn()
                    }
                }
            }
            cm.registerNetworkCallback(request, networkCallback!!)
        } catch (_: Exception) {}
    }

    private fun unregisterNetworkCallback() {
        try {
            if (networkCallback != null) {
                val cm = getSystemService(Context.CONNECTIVITY_SERVICE) as? ConnectivityManager
                cm?.unregisterNetworkCallback(networkCallback!!)
                networkCallback = null
            }
        } catch (_: Exception) {}
    }

    private fun startVpn(allowedPackages: List<String>?) {
        if (isRunning) return

        // Verify device has active Wi-Fi or Mobile Data
        if (!NetworkUtils.isNetworkConnected(this)) {
            stopVpn()
            return
        }

        startForegroundNotification()

        try {
            val dnsServers = getSystemDnsServers()
            val builder = Builder()
                .setSession("TrafficTracker")
                .addAddress("10.0.0.2", 32)
                .addRoute("0.0.0.0", 0)
                .setMtu(1500)

            for (dns in dnsServers) {
                try {
                    builder.addDnsServer(dns)
                } catch (_: Exception) {}
            }

            // Do not route our own traffic through the VPN to avoid loops
            try {
                builder.addDisallowedApplication(packageName)
            } catch (_: Exception) {}

            // Apply per-app filtering on the TUN interface if specified
            if (!allowedPackages.isNullOrEmpty()) {
                for (pkg in allowedPackages) {
                    try {
                        builder.addAllowedApplication(pkg)
                    } catch (_: Exception) {}
                }
            }

            vpnInterface = builder.establish()
            if (vpnInterface == null) {
                stopSelf()
                return
            }

            tunOutputStream = FileOutputStream(vpnInterface!!.fileDescriptor)
            forwarder = VpnForwarder(
                vpnService = this,
                tunWriter = { packet -> writeToTun(packet) },
                defaultDnsServers = dnsServers
            )

            initPcapFile()
            registerNetworkCallback()

            isRunning = true
            isThreadRunning = true
            packetCount = 0L
            totalBytesCaptured = 0L

            sendEvent(mapOf(
                "type" to "STATUS_CHANGED",
                "isRunning" to true,
                "pcapPath" to pcapFilePath
            ))

            vpnThread = Thread({ processPackets() }, "TrafficTrackerVpnThread").apply { start() }

        } catch (e: Exception) {
            e.printStackTrace()
            stopVpn()
        }
    }

    private fun initPcapFile() {
        try {
            val file = File(filesDir, "traffic_capture_${System.currentTimeMillis()}.pcap")
            pcapFilePath = file.absolutePath
            val fos = FileOutputStream(file)

            val header = ByteBuffer.allocate(24).order(ByteOrder.LITTLE_ENDIAN)
            header.putInt(0xa1b2c3d4.toInt()) // magic_number
            header.putShort(2.toShort())       // version_major
            header.putShort(4.toShort())       // version_minor
            header.putInt(0)                   // thiszone
            header.putInt(0)                   // sigfigs
            header.putInt(65535)               // snaplen
            header.putInt(12)                  // DLT_RAW (12)

            fos.write(header.array())
            fos.flush()
            pcapOutputStream = fos
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun writePcapPacket(packetData: ByteArray, length: Int) {
        val fos = pcapOutputStream ?: return
        try {
            val nowMs = System.currentTimeMillis()
            val sec = (nowMs / 1000).toInt()
            val usec = ((nowMs % 1000) * 1000).toInt()

            val pcapHeader = ByteBuffer.allocate(16).order(ByteOrder.LITTLE_ENDIAN)
            pcapHeader.putInt(sec)
            pcapHeader.putInt(usec)
            pcapHeader.putInt(length)
            pcapHeader.putInt(length)

            synchronized(this) {
                fos.write(pcapHeader.array())
                fos.write(packetData, 0, length)
            }
        } catch (_: Exception) {}
    }

    private fun processPackets() {
        val descriptor = vpnInterface?.fileDescriptor ?: return
        val inputStream = FileInputStream(descriptor)
        val buffer = ByteArray(32767)

        while (isThreadRunning) {
            try {
                val length = inputStream.read(buffer)
                if (length > 0) {
                    parseAndProcessPacket(buffer, length)
                }
            } catch (e: IOException) {
                break
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
    }

    private fun parseAndProcessPacket(packet: ByteArray, length: Int) {
        if (length < 20) return

        val versionAndIhl = packet[0].toInt() and 0xFF
        val version = versionAndIhl shr 4
        if (version != 4) return // IPv4 supported

        val ihl = (versionAndIhl and 0x0F) * 4
        if (length < ihl) return

        val protocol = packet[9].toInt() and 0xFF
        val srcIp = "${packet[12].toInt() and 0xFF}.${packet[13].toInt() and 0xFF}.${packet[14].toInt() and 0xFF}.${packet[15].toInt() and 0xFF}"
        val dstIp = "${packet[16].toInt() and 0xFF}.${packet[17].toInt() and 0xFF}.${packet[18].toInt() and 0xFF}.${packet[19].toInt() and 0xFF}"

        var srcPort = 0
        var dstPort = 0
        var protocolName = "IP"
        var domain: String? = null
        var resolvedPkgName: String? = null
        var resolvedAppName: String? = null

        var tcpFlags = 0
        var tcpSeqNum = 0L
        var tcpAckNum = 0L
        var tcpPayload = ByteArray(0)
        var udpPayload = ByteArray(0)

        if (protocol == 6 && length >= ihl + 20) { // TCP
            protocolName = "TCP"
            srcPort = ((packet[ihl].toInt() and 0xFF) shl 8) or (packet[ihl + 1].toInt() and 0xFF)
            dstPort = ((packet[ihl + 2].toInt() and 0xFF) shl 8) or (packet[ihl + 3].toInt() and 0xFF)

            tcpSeqNum = ((packet[ihl + 4].toLong() and 0xFF) shl 24) or
                    ((packet[ihl + 5].toLong() and 0xFF) shl 16) or
                    ((packet[ihl + 6].toLong() and 0xFF) shl 8) or
                    (packet[ihl + 7].toLong() and 0xFF)

            tcpAckNum = ((packet[ihl + 8].toLong() and 0xFF) shl 24) or
                    ((packet[ihl + 9].toLong() and 0xFF) shl 16) or
                    ((packet[ihl + 10].toLong() and 0xFF) shl 8) or
                    (packet[ihl + 11].toLong() and 0xFF)

            val tcpDataOffset = ((packet[ihl + 12].toInt() and 0xFF) shr 4) * 4
            tcpFlags = packet[ihl + 13].toInt() and 0xFF
            val payloadOffset = ihl + tcpDataOffset

            if (length > payloadOffset) {
                tcpPayload = packet.copyOfRange(payloadOffset, length)
            }

            if (dstPort == 443 && length > payloadOffset + 5) {
                domain = extractSniFromTls(packet, payloadOffset, length)
                if (domain != null) {
                    protocolName = "TLS/HTTPS"
                }
            } else if (dstPort == 80) {
                protocolName = "HTTP"
            }
        } else if (protocol == 17 && length >= ihl + 8) { // UDP
            protocolName = "UDP"
            srcPort = ((packet[ihl].toInt() and 0xFF) shl 8) or (packet[ihl + 1].toInt() and 0xFF)
            dstPort = ((packet[ihl + 2].toInt() and 0xFF) shl 8) or (packet[ihl + 3].toInt() and 0xFF)

            if (length > ihl + 8) {
                udpPayload = packet.copyOfRange(ihl + 8, length)
            }

            if (dstPort == 53 && length > ihl + 8 + 12) {
                domain = extractDnsQueryName(packet, ihl + 8, length)
                protocolName = "DNS"
            }
        }

        // Identify originating app on Android 10+ (API 29+)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q && (protocol == 6 || protocol == 17)) {
            try {
                val cm = getSystemService(Context.CONNECTIVITY_SERVICE) as? ConnectivityManager
                if (cm != null && srcPort > 0 && dstPort > 0) {
                    val srcAddr = InetSocketAddress(InetAddress.getByName(srcIp), srcPort)
                    val dstAddr = InetSocketAddress(InetAddress.getByName(dstIp), dstPort)
                    val uid = cm.getConnectionOwnerUid(protocol, srcAddr, dstAddr)
                    if (uid > 0) {
                        val pkgs = packageManager.getPackagesForUid(uid)
                        if (!pkgs.isNullOrEmpty()) {
                            resolvedPkgName = pkgs[0]
                            val appInfo = packageManager.getApplicationInfo(resolvedPkgName, 0)
                            resolvedAppName = packageManager.getApplicationLabel(appInfo).toString()
                        }
                    }
                }
            } catch (_: Exception) {}
        }

        // Forward packets to the real internet via Userspace Forwarder / NAT engine
        if (protocol == 6 && srcPort > 0 && dstPort > 0) {
            forwarder?.forwardTcp(srcIp, srcPort, dstIp, dstPort, tcpFlags, tcpSeqNum, tcpAckNum, tcpPayload)
        } else if (protocol == 17 && srcPort > 0 && dstPort > 0) {
            if (dstPort == 53) {
                forwarder?.forwardDns(srcIp, srcPort, dstIp, dstPort, udpPayload)
            } else {
                forwarder?.forwardGeneralUdp(srcIp, srcPort, dstIp, dstPort, udpPayload)
            }
        }

        // Active app filtering check for UI inspection reporting
        synchronized(allowedPackageSet) {
            if (allowedPackageSet.isNotEmpty()) {
                if (resolvedPkgName != null && !allowedPackageSet.contains(resolvedPkgName)) {
                    return // Exclude packet from reporting if not in selected apps
                }
            }
        }

        packetCount++
        totalBytesCaptured += length
        writePcapPacket(packet, length)

        val event = mapOf(
            "type" to "PACKET",
            "timestamp" to System.currentTimeMillis(),
            "protocol" to protocolName,
            "srcIp" to srcIp,
            "srcPort" to srcPort,
            "dstIp" to dstIp,
            "dstPort" to dstPort,
            "domain" to domain,
            "packageName" to resolvedPkgName,
            "appName" to resolvedAppName,
            "length" to length,
            "totalPackets" to packetCount,
            "totalBytes" to totalBytesCaptured
        )

        sendEvent(event)
    }

    private fun extractSniFromTls(packet: ByteArray, offset: Int, length: Int): String? {
        try {
            if (packet[offset] != 0x16.toByte()) return null
            if (length < offset + 9) return null

            val handshakeType = packet[offset + 5].toInt() and 0xFF
            if (handshakeType != 1) return null // Client Hello

            var pos = offset + 9
            pos += 34
            if (pos >= length) return null

            val sessionIdLen = packet[pos].toInt() and 0xFF
            pos += 1 + sessionIdLen
            if (pos + 2 >= length) return null

            val cipherSuitesLen = ((packet[pos].toInt() and 0xFF) shl 8) or (packet[pos + 1].toInt() and 0xFF)
            pos += 2 + cipherSuitesLen
            if (pos + 1 >= length) return null

            val compressionLen = packet[pos].toInt() and 0xFF
            pos += 1 + compressionLen
            if (pos + 2 >= length) return null

            val extensionsLen = ((packet[pos].toInt() and 0xFF) shl 8) or (packet[pos + 1].toInt() and 0xFF)
            pos += 2
            val extensionsEnd = Math.min(pos + extensionsLen, length)

            while (pos + 4 <= extensionsEnd) {
                val extType = ((packet[pos].toInt() and 0xFF) shl 8) or (packet[pos + 1].toInt() and 0xFF)
                val extLen = ((packet[pos + 2].toInt() and 0xFF) shl 8) or (packet[pos + 3].toInt() and 0xFF)
                pos += 4

                if (extType == 0) { // server_name
                    if (pos + 5 <= extensionsEnd) {
                        val nameType = packet[pos + 2].toInt() and 0xFF
                        val nameLen = ((packet[pos + 3].toInt() and 0xFF) shl 8) or (packet[pos + 4].toInt() and 0xFF)
                        if (nameType == 0 && pos + 5 + nameLen <= extensionsEnd) {
                            return String(packet, pos + 5, nameLen, Charsets.US_ASCII)
                        }
                    }
                }
                pos += extLen
            }
        } catch (_: Exception) {}
        return null
    }

    private fun extractDnsQueryName(packet: ByteArray, udpPayloadOffset: Int, totalLength: Int): String? {
        try {
            var pos = udpPayloadOffset + 12
            val domainBuilder = StringBuilder()

            while (pos < totalLength) {
                val labelLen = packet[pos].toInt() and 0xFF
                if (labelLen == 0) break
                pos++

                if (pos + labelLen > totalLength) return null

                if (domainBuilder.isNotEmpty()) {
                    domainBuilder.append('.')
                }
                domainBuilder.append(String(packet, pos, labelLen, Charsets.US_ASCII))
                pos += labelLen
            }

            return if (domainBuilder.isNotEmpty()) domainBuilder.toString() else null
        } catch (_: Exception) {}
        return null
    }

    private fun startForegroundNotification() {
        val channelId = "traffic_vpn_channel"
        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                channelId,
                "خدمة مراقبة الشبكة (Traffic Tracker)",
                NotificationManager.IMPORTANCE_LOW
            )
            channel.description = "إشعار استمرار فحص حركة مرور حزم الشبكة"
            notificationManager.createNotificationChannel(channel)
        }

        val launchIntent = packageManager.getLaunchIntentForPackage(packageName)
        val pendingIntent = PendingIntent.getActivity(
            this,
            0,
            launchIntent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )

        val notification: Notification = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(this, channelId)
                .setContentTitle("مراقب الشبكة نشط")
                .setContentText("يتم فحص وتسجيل حزم الشبكة محلياً")
                .setSmallIcon(android.R.drawable.stat_notify_sync)
                .setContentIntent(pendingIntent)
                .setOngoing(true)
                .build()
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(this)
                .setContentTitle("مراقب الشبكة نشط")
                .setContentText("يتم فحص وتسجيل حزم الشبكة محلياً")
                .setSmallIcon(android.R.drawable.stat_notify_sync)
                .setContentIntent(pendingIntent)
                .setOngoing(true)
                .build()
        }

        startForeground(1001, notification)
    }

    private fun stopVpn() {
        unregisterNetworkCallback()

        isThreadRunning = false
        isRunning = false

        try {
            forwarder?.stop()
            forwarder = null
        } catch (_: Exception) {}

        try {
            vpnThread?.interrupt()
            vpnInterface?.close()
            vpnInterface = null
        } catch (_: Exception) {}

        try {
            tunOutputStream?.close()
            tunOutputStream = null
        } catch (_: Exception) {}

        try {
            pcapOutputStream?.flush()
            pcapOutputStream?.close()
            pcapOutputStream = null
        } catch (_: Exception) {}

        sendEvent(mapOf(
            "type" to "STATUS_CHANGED",
            "isRunning" to false,
            "pcapPath" to pcapFilePath
        ))

        stopForeground(STOP_FOREGROUND_REMOVE)
        stopSelf()
    }

    override fun onDestroy() {
        stopVpn()
        super.onDestroy()
    }
}
