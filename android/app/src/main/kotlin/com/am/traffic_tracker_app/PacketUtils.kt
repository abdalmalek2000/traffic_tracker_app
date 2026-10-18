package com.am.traffic_tracker_app

import java.net.InetAddress
import java.nio.ByteBuffer
import java.nio.ByteOrder

/**
 * Utility for parsing and synthesizing raw IPv4, UDP, and TCP packets
 * for the Userspace Forwarder / NAT engine.
 */
object PacketUtils {

    const val TCP_FLAG_FIN = 0x01
    const val TCP_FLAG_SYN = 0x02
    const val TCP_FLAG_RST = 0x04
    const val TCP_FLAG_PSH = 0x08
    const val TCP_FLAG_ACK = 0x10
    const val TCP_FLAG_URG = 0x20

    /**
     * Computes the standard 16-bit Internet Checksum (One's complement sum).
     */
    fun computeChecksum(data: ByteArray, offset: Int, length: Int): Short {
        var sum = 0
        var i = offset
        val end = offset + length
        while (i < end - 1) {
            val word = ((data[i].toInt() and 0xFF) shl 8) or (data[i + 1].toInt() and 0xFF)
            sum += word
            i += 2
        }
        if (i < end) {
            sum += ((data[i].toInt() and 0xFF) shl 8)
        }
        while ((sum shr 16) != 0) {
            sum = (sum and 0xFFFF) + (sum shr 16)
        }
        val res = (sum.inv() and 0xFFFF)
        return if (res == 0) 0xFFFF.toShort() else res.toShort()
    }

    /**
     * Computes the standard TCP checksum including the IPv4 pseudo-header.
     */
    fun computeTcpChecksum(
        srcIpBytes: ByteArray,
        dstIpBytes: ByteArray,
        tcpData: ByteArray,
        tcpOffset: Int,
        tcpLength: Int
    ): Short {
        var sum = 0
        // IPv4 Pseudo Header: Source IP (4) + Destination IP (4) + Zero (1) + Protocol (1) + TCP Length (2)
        sum += ((srcIpBytes[0].toInt() and 0xFF) shl 8) or (srcIpBytes[1].toInt() and 0xFF)
        sum += ((srcIpBytes[2].toInt() and 0xFF) shl 8) or (srcIpBytes[3].toInt() and 0xFF)
        sum += ((dstIpBytes[0].toInt() and 0xFF) shl 8) or (dstIpBytes[1].toInt() and 0xFF)
        sum += ((dstIpBytes[2].toInt() and 0xFF) shl 8) or (dstIpBytes[3].toInt() and 0xFF)
        sum += 6 // IPPROTO_TCP
        sum += tcpLength

        // TCP Header and Payload
        var i = tcpOffset
        val end = tcpOffset + tcpLength
        while (i < end - 1) {
            val word = ((tcpData[i].toInt() and 0xFF) shl 8) or (tcpData[i + 1].toInt() and 0xFF)
            sum += word
            i += 2
        }
        if (i < end) {
            sum += ((tcpData[i].toInt() and 0xFF) shl 8)
        }
        while ((sum shr 16) != 0) {
            sum = (sum and 0xFFFF) + (sum shr 16)
        }
        val res = (sum.inv() and 0xFFFF)
        return if (res == 0) 0xFFFF.toShort() else res.toShort()
    }

    /**
     * Builds a full IPv4 + UDP packet with proper checksums.
     */
    fun buildUdpPacket(
        srcIp: String,
        srcPort: Int,
        dstIp: String,
        dstPort: Int,
        payload: ByteArray
    ): ByteArray {
        val ipLen = 20
        val udpLen = 8
        val totalLen = ipLen + udpLen + payload.size
        val packet = ByteArray(totalLen)
        val buffer = ByteBuffer.wrap(packet).order(ByteOrder.BIG_ENDIAN)

        val srcBytes = InetAddress.getByName(srcIp).address
        val dstBytes = InetAddress.getByName(dstIp).address

        // IPv4 Header
        buffer.put(0x45.toByte()) // IPv4, IHL = 5 (20 bytes)
        buffer.put(0x00.toByte()) // DSCP/ECN
        buffer.putShort(totalLen.toShort())
        buffer.putShort(0.toShort()) // Identification
        buffer.putShort(0x4000.toShort()) // Flags (Don't Fragment)
        buffer.put(64.toByte()) // TTL
        buffer.put(17.toByte()) // Protocol UDP (17)
        buffer.putShort(0.toShort()) // Header checksum placeholder
        buffer.put(srcBytes)
        buffer.put(dstBytes)

        // Calculate IPv4 Checksum
        val ipChecksum = computeChecksum(packet, 0, ipLen)
        packet[10] = ((ipChecksum.toInt() shr 8) and 0xFF).toByte()
        packet[11] = (ipChecksum.toInt() and 0xFF).toByte()

        // UDP Header
        buffer.position(ipLen)
        buffer.putShort(srcPort.toShort())
        buffer.putShort(dstPort.toShort())
        buffer.putShort((udpLen + payload.size).toShort())
        buffer.putShort(0.toShort()) // Checksum 0 is valid in IPv4 UDP
        buffer.put(payload)

        return packet
    }

    /**
     * Builds a full IPv4 + TCP packet with proper checksums.
     */
    fun buildTcpPacket(
        srcIp: String,
        srcPort: Int,
        dstIp: String,
        dstPort: Int,
        seqNum: Long,
        ackNum: Long,
        flags: Int,
        windowSize: Int = 65535,
        payload: ByteArray? = null
    ): ByteArray {
        val ipLen = 20
        val tcpLen = 20
        val payloadLen = payload?.size ?: 0
        val totalLen = ipLen + tcpLen + payloadLen
        val packet = ByteArray(totalLen)
        val buffer = ByteBuffer.wrap(packet).order(ByteOrder.BIG_ENDIAN)

        val srcBytes = InetAddress.getByName(srcIp).address
        val dstBytes = InetAddress.getByName(dstIp).address

        // IPv4 Header
        buffer.put(0x45.toByte()) // IPv4, IHL = 5
        buffer.put(0x00.toByte())
        buffer.putShort(totalLen.toShort())
        buffer.putShort(0.toShort())
        buffer.putShort(0x4000.toShort())
        buffer.put(64.toByte())
        buffer.put(6.toByte()) // Protocol TCP (6)
        buffer.putShort(0.toShort())
        buffer.put(srcBytes)
        buffer.put(dstBytes)

        // IPv4 Checksum
        val ipChecksum = computeChecksum(packet, 0, ipLen)
        packet[10] = ((ipChecksum.toInt() shr 8) and 0xFF).toByte()
        packet[11] = (ipChecksum.toInt() and 0xFF).toByte()

        // TCP Header
        buffer.position(ipLen)
        buffer.putShort(srcPort.toShort())
        buffer.putShort(dstPort.toShort())
        buffer.putInt(seqNum.toInt())
        buffer.putInt(ackNum.toInt())
        buffer.put(0x50.toByte()) // Data Offset: 5 (20 bytes)
        buffer.put(flags.toByte())
        buffer.putShort(windowSize.toShort())
        buffer.putShort(0.toShort()) // TCP Checksum placeholder
        buffer.putShort(0.toShort()) // Urgent pointer

        if (payload != null && payload.isNotEmpty()) {
            buffer.put(payload)
        }

        // TCP Checksum
        val tcpChecksum = computeTcpChecksum(srcBytes, dstBytes, packet, ipLen, tcpLen + payloadLen)
        packet[ipLen + 16] = ((tcpChecksum.toInt() shr 8) and 0xFF).toByte()
        packet[ipLen + 17] = (tcpChecksum.toInt() and 0xFF).toByte()

        return packet
    }

    fun buildTcpSynAck(
        srcIp: String,
        srcPort: Int,
        dstIp: String,
        dstPort: Int,
        seqNum: Long,
        ackNum: Long
    ): ByteArray {
        return buildTcpPacket(
            srcIp = srcIp,
            srcPort = srcPort,
            dstIp = dstIp,
            dstPort = dstPort,
            seqNum = seqNum,
            ackNum = ackNum,
            flags = TCP_FLAG_SYN or TCP_FLAG_ACK,
            windowSize = 65535
        )
    }

    fun buildTcpAck(
        srcIp: String,
        srcPort: Int,
        dstIp: String,
        dstPort: Int,
        seqNum: Long,
        ackNum: Long
    ): ByteArray {
        return buildTcpPacket(
            srcIp = srcIp,
            srcPort = srcPort,
            dstIp = dstIp,
            dstPort = dstPort,
            seqNum = seqNum,
            ackNum = ackNum,
            flags = TCP_FLAG_ACK,
            windowSize = 65535
        )
    }

    fun buildTcpRst(
        srcIp: String,
        srcPort: Int,
        dstIp: String,
        dstPort: Int,
        seqNum: Long,
        ackNum: Long
    ): ByteArray {
        return buildTcpPacket(
            srcIp = srcIp,
            srcPort = srcPort,
            dstIp = dstIp,
            dstPort = dstPort,
            seqNum = seqNum,
            ackNum = ackNum,
            flags = TCP_FLAG_RST or TCP_FLAG_ACK,
            windowSize = 0
        )
    }

    fun buildTcpDataPacket(
        srcIp: String,
        srcPort: Int,
        dstIp: String,
        dstPort: Int,
        seqNum: Long,
        ackNum: Long,
        payload: ByteArray
    ): ByteArray {
        return buildTcpPacket(
            srcIp = srcIp,
            srcPort = srcPort,
            dstIp = dstIp,
            dstPort = dstPort,
            seqNum = seqNum,
            ackNum = ackNum,
            flags = TCP_FLAG_PSH or TCP_FLAG_ACK,
            windowSize = 65535,
            payload = payload
        )
    }

    fun buildTcpFin(
        srcIp: String,
        srcPort: Int,
        dstIp: String,
        dstPort: Int,
        seqNum: Long,
        ackNum: Long
    ): ByteArray {
        return buildTcpPacket(
            srcIp = srcIp,
            srcPort = srcPort,
            dstIp = dstIp,
            dstPort = dstPort,
            seqNum = seqNum,
            ackNum = ackNum,
            flags = TCP_FLAG_FIN or TCP_FLAG_ACK,
            windowSize = 65535
        )
    }
}
