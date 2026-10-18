package com.am.traffic_tracker_app

import android.net.VpnService
import android.util.Log
import java.io.InputStream
import java.io.OutputStream
import java.net.DatagramPacket
import java.net.DatagramSocket
import java.net.InetAddress
import java.net.InetSocketAddress
import java.net.Socket
import java.util.concurrent.ConcurrentHashMap
import java.util.concurrent.Executors
import java.util.concurrent.ScheduledExecutorService
import java.util.concurrent.TimeUnit
import java.util.concurrent.atomic.AtomicBoolean

/**
 * Userspace Forwarder / NAT engine that relays DNS and TCP traffic
 * intercepted from Android's TUN interface over protected sockets.
 */
class VpnForwarder(
    private val vpnService: VpnService,
    private val tunWriter: (ByteArray) -> Unit,
    private val defaultDnsServers: List<String>
) {
    companion object {
        private const val TAG = "VpnForwarder"
        private const val CONNECT_TIMEOUT_MS = 6000
        private const val SOCKET_TIMEOUT_MS = 60000
        private const val CHUNK_SIZE = 1400 // MTU-safe chunk
    }

    private val isRunning = AtomicBoolean(true)
    private val dnsExecutor = Executors.newFixedThreadPool(8)
    private val tcpExecutor = Executors.newCachedThreadPool()
    private val cleanupScheduler: ScheduledExecutorService = Executors.newSingleThreadScheduledExecutor()

    private val tcpSessions = ConcurrentHashMap<String, TcpSession>()

    init {
        // Periodically prune idle or terminated TCP sessions every 30 seconds
        cleanupScheduler.scheduleWithFixedDelay({
            try {
                val now = System.currentTimeMillis()
                val iterator = tcpSessions.entries.iterator()
                while (iterator.hasNext()) {
                    val entry = iterator.next()
                    val session = entry.value
                    if (!session.isRunning.get() || (now - session.lastActiveTime > 60000)) {
                        session.close()
                        iterator.remove()
                    }
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error in cleanupScheduler: ${e.message}")
            }
        }, 30, 30, TimeUnit.SECONDS)
    }

    /**
     * Forwards a DNS query (UDP 53) via a protected DatagramSocket
     * and injects the DNS response back into the TUN interface.
     */
    fun forwardDns(
        srcIp: String,
        srcPort: Int,
        dstIp: String,
        dstPort: Int,
        dnsQuery: ByteArray
    ) {
        if (!isRunning.get()) return

        dnsExecutor.execute {
            var socket: DatagramSocket? = null
            try {
                socket = DatagramSocket()
                vpnService.protect(socket)
                socket.soTimeout = 4000

                // Use requested DNS or fallback to first available system DNS
                val targetDns = if (dstIp == "10.0.0.2" || dstIp.startsWith("127.")) {
                    defaultDnsServers.firstOrNull() ?: "8.8.8.8"
                } else {
                    dstIp
                }

                val outPacket = DatagramPacket(
                    dnsQuery,
                    dnsQuery.size,
                    InetAddress.getByName(targetDns),
                    dstPort
                )
                socket.send(outPacket)

                val responseBuf = ByteArray(2048)
                val inPacket = DatagramPacket(responseBuf, responseBuf.size)
                socket.receive(inPacket)

                val dnsResponse = responseBuf.copyOf(inPacket.length)

                // Synthesize UDP response packet for TUN
                val tunPacket = PacketUtils.buildUdpPacket(
                    srcIp = dstIp,
                    srcPort = dstPort,
                    dstIp = srcIp,
                    dstPort = srcPort,
                    payload = dnsResponse
                )
                tunWriter(tunPacket)
            } catch (e: Exception) {
                Log.d(TAG, "DNS query forward error for $srcIp:$srcPort -> $dstIp:$dstPort: ${e.message}")
            } finally {
                try {
                    socket?.close()
                } catch (_: Exception) {}
            }
        }
    }

    /**
     * Forwards general UDP traffic (e.g., NTP) via a protected DatagramSocket.
     */
    fun forwardGeneralUdp(
        srcIp: String,
        srcPort: Int,
        dstIp: String,
        dstPort: Int,
        payload: ByteArray
    ) {
        if (!isRunning.get()) return

        dnsExecutor.execute {
            var socket: DatagramSocket? = null
            try {
                socket = DatagramSocket()
                vpnService.protect(socket)
                socket.soTimeout = 3000

                val outPacket = DatagramPacket(
                    payload,
                    payload.size,
                    InetAddress.getByName(dstIp),
                    dstPort
                )
                socket.send(outPacket)

                val responseBuf = ByteArray(2048)
                val inPacket = DatagramPacket(responseBuf, responseBuf.size)
                socket.receive(inPacket)

                val udpResponse = responseBuf.copyOf(inPacket.length)
                val tunPacket = PacketUtils.buildUdpPacket(
                    srcIp = dstIp,
                    srcPort = dstPort,
                    dstIp = srcIp,
                    dstPort = srcPort,
                    payload = udpResponse
                )
                tunWriter(tunPacket)
            } catch (_: Exception) {
            } finally {
                try {
                    socket?.close()
                } catch (_: Exception) {}
            }
        }
    }

    /**
     * Processes incoming TCP packets from the TUN interface, managing connection state,
     * handshakes, data relaying, and teardown.
     */
    fun forwardTcp(
        srcIp: String,
        srcPort: Int,
        dstIp: String,
        dstPort: Int,
        flags: Int,
        seqNum: Long,
        ackNum: Long,
        payload: ByteArray
    ) {
        if (!isRunning.get()) return

        val sessionKey = "$srcPort->$dstIp:$dstPort"
        val isSyn = (flags and PacketUtils.TCP_FLAG_SYN) != 0
        val isAck = (flags and PacketUtils.TCP_FLAG_ACK) != 0
        val isFin = (flags and PacketUtils.TCP_FLAG_FIN) != 0
        val isRst = (flags and PacketUtils.TCP_FLAG_RST) != 0

        if (isSyn && !isAck) {
            handleTcpSyn(sessionKey, srcIp, srcPort, dstIp, dstPort, seqNum)
            return
        }

        val session = tcpSessions[sessionKey]
        if (session == null) {
            // Unsolicited packet or already closed session; send RST if not a RST itself
            if (!isRst) {
                sendRst(srcIp, srcPort, dstIp, dstPort, 0, seqNum + 1)
            }
            return
        }

        session.lastActiveTime = System.currentTimeMillis()

        if (isRst) {
            session.close()
            tcpSessions.remove(sessionKey)
            return
        }

        if (isFin) {
            handleTcpFin(session, srcIp, srcPort, dstIp, dstPort, seqNum)
            return
        }

        if (payload.isNotEmpty()) {
            handleTcpData(session, srcIp, srcPort, dstIp, dstPort, seqNum, payload)
        }
    }

    private fun handleTcpSyn(
        sessionKey: String,
        srcIp: String,
        srcPort: Int,
        dstIp: String,
        dstPort: Int,
        clientInitialSeq: Long
    ) {
        val existing = tcpSessions[sessionKey]
        if (existing != null && existing.isConnected.get()) {
            // Retransmitted SYN: resend SYN-ACK
            val synAck = PacketUtils.buildTcpSynAck(
                srcIp = dstIp,
                srcPort = dstPort,
                dstIp = srcIp,
                dstPort = srcPort,
                seqNum = existing.serverSeq,
                ackNum = clientInitialSeq + 1
            )
            tunWriter(synAck)
            return
        }

        val session = TcpSession(
            key = sessionKey,
            srcIp = srcIp,
            srcPort = srcPort,
            dstIp = dstIp,
            dstPort = dstPort,
            clientSeq = clientInitialSeq + 1,
            serverSeq = (System.currentTimeMillis() and 0x7FFFFFFF)
        )
        tcpSessions[sessionKey] = session

        tcpExecutor.execute {
            var socket: Socket? = null
            try {
                socket = Socket()
                vpnService.protect(socket)
                socket.tcpNoDelay = true
                socket.soTimeout = SOCKET_TIMEOUT_MS

                socket.connect(InetSocketAddress(dstIp, dstPort), CONNECT_TIMEOUT_MS)

                session.socket = socket
                session.isConnected.set(true)

                // Send SYN-ACK to TUN
                val synAck = PacketUtils.buildTcpSynAck(
                    srcIp = dstIp,
                    srcPort = dstPort,
                    dstIp = srcIp,
                    dstPort = srcPort,
                    seqNum = session.serverSeq,
                    ackNum = session.clientSeq
                )
                tunWriter(synAck)
                session.serverSeq += 1

                // Start reader thread from remote socket to TUN
                startRemoteReader(session)

            } catch (e: Exception) {
                Log.d(TAG, "Connection failed to $dstIp:$dstPort: ${e.message}")
                sendRst(srcIp, srcPort, dstIp, dstPort, 0, clientInitialSeq + 1)
                session.close()
                tcpSessions.remove(sessionKey)
            }
        }
    }

    private fun startRemoteReader(session: TcpSession) {
        tcpExecutor.execute {
            val socket = session.socket ?: return@execute
            var inputStream: InputStream? = null
            try {
                inputStream = socket.getInputStream()
                val buffer = ByteArray(CHUNK_SIZE)
                while (isRunning.get() && session.isRunning.get()) {
                    val bytesRead = inputStream.read(buffer)
                    if (bytesRead == -1) break

                    session.lastActiveTime = System.currentTimeMillis()
                    val chunk = buffer.copyOf(bytesRead)

                    val dataPacket = PacketUtils.buildTcpDataPacket(
                        srcIp = session.dstIp,
                        srcPort = session.dstPort,
                        dstIp = session.srcIp,
                        dstPort = session.srcPort,
                        seqNum = session.serverSeq,
                        ackNum = session.clientSeq,
                        payload = chunk
                    )
                    tunWriter(dataPacket)
                    session.serverSeq += bytesRead
                }

                // Remote closed stream: send FIN-ACK to TUN
                if (session.isRunning.get()) {
                    val finPacket = PacketUtils.buildTcpFin(
                        srcIp = session.dstIp,
                        srcPort = session.dstPort,
                        dstIp = session.srcIp,
                        dstPort = session.srcPort,
                        seqNum = session.serverSeq,
                        ackNum = session.clientSeq
                    )
                    tunWriter(finPacket)
                    session.serverSeq += 1
                }
            } catch (_: Exception) {
            } finally {
                session.close()
                tcpSessions.remove(session.key)
            }
        }
    }

    private fun handleTcpData(
        session: TcpSession,
        srcIp: String,
        srcPort: Int,
        dstIp: String,
        dstPort: Int,
        seqNum: Long,
        payload: ByteArray
    ) {
        tcpExecutor.execute {
            try {
                val outputStream: OutputStream? = session.socket?.getOutputStream()
                if (outputStream != null) {
                    outputStream.write(payload)
                    outputStream.flush()

                    session.clientSeq = seqNum + payload.size

                    // Send ACK back to TUN acknowledging received data
                    val ackPacket = PacketUtils.buildTcpAck(
                        srcIp = dstIp,
                        srcPort = dstPort,
                        dstIp = srcIp,
                        dstPort = srcPort,
                        seqNum = session.serverSeq,
                        ackNum = session.clientSeq
                    )
                    tunWriter(ackPacket)
                }
            } catch (e: Exception) {
                Log.d(TAG, "Failed forwarding TCP payload to $dstIp:$dstPort: ${e.message}")
                sendRst(srcIp, srcPort, dstIp, dstPort, session.serverSeq, seqNum + payload.size)
                session.close()
                tcpSessions.remove(session.key)
            }
        }
    }

    private fun handleTcpFin(
        session: TcpSession,
        srcIp: String,
        srcPort: Int,
        dstIp: String,
        dstPort: Int,
        seqNum: Long
    ) {
        tcpExecutor.execute {
            try {
                session.clientSeq = seqNum + 1
                // Send FIN-ACK response
                val finAck = PacketUtils.buildTcpFin(
                    srcIp = dstIp,
                    srcPort = dstPort,
                    dstIp = srcIp,
                    dstPort = srcPort,
                    seqNum = session.serverSeq,
                    ackNum = session.clientSeq
                )
                tunWriter(finAck)
            } catch (_: Exception) {
            } finally {
                session.close()
                tcpSessions.remove(session.key)
            }
        }
    }

    private fun sendRst(
        srcIp: String,
        srcPort: Int,
        dstIp: String,
        dstPort: Int,
        seqNum: Long,
        ackNum: Long
    ) {
        try {
            val rstPacket = PacketUtils.buildTcpRst(
                srcIp = dstIp,
                srcPort = dstPort,
                dstIp = srcIp,
                dstPort = srcPort,
                seqNum = seqNum,
                ackNum = ackNum
            )
            tunWriter(rstPacket)
        } catch (_: Exception) {}
    }

    /**
     * Stops the forwarder and terminates all active sockets and pools.
     */
    fun stop() {
        isRunning.set(false)
        cleanupScheduler.shutdownNow()
        dnsExecutor.shutdownNow()
        tcpExecutor.shutdownNow()

        for (session in tcpSessions.values) {
            session.close()
        }
        tcpSessions.clear()
    }

    /**
     * Represents an active TCP session between an application and a remote endpoint.
     */
    private class TcpSession(
        val key: String,
        val srcIp: String,
        val srcPort: Int,
        val dstIp: String,
        val dstPort: Int,
        @Volatile var clientSeq: Long,
        @Volatile var serverSeq: Long
    ) {
        var socket: Socket? = null
        val isConnected = AtomicBoolean(false)
        val isRunning = AtomicBoolean(true)
        @Volatile var lastActiveTime: Long = System.currentTimeMillis()

        fun close() {
            isRunning.set(false)
            try {
                socket?.close()
            } catch (_: Exception) {}
            socket = null
        }
    }
}
