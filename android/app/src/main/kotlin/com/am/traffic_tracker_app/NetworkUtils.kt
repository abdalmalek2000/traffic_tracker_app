package com.am.traffic_tracker_app

import android.content.Context
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import android.os.Build

object NetworkUtils {

    /**
     * Checks if the device is currently connected to a physical network
     * (Wi-Fi, Cellular Mobile Data, or Ethernet).
     * Excludes virtual VPN interfaces to ensure real underlying connectivity.
     */
    fun isNetworkConnected(context: Context): Boolean {
        val cm = context.getSystemService(Context.CONNECTIVITY_SERVICE) as? ConnectivityManager
            ?: return false

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val networks = cm.allNetworks
            for (network in networks) {
                val caps = cm.getNetworkCapabilities(network) ?: continue

                // Ignore pure VPN virtual networks
                val isVpn = caps.hasTransport(NetworkCapabilities.TRANSPORT_VPN)
                if (isVpn) continue

                val hasWifi = caps.hasTransport(NetworkCapabilities.TRANSPORT_WIFI)
                val hasCellular = caps.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR)
                val hasEthernet = caps.hasTransport(NetworkCapabilities.TRANSPORT_ETHERNET)

                if (hasWifi || hasCellular || hasEthernet) {
                    return true
                }
            }
            return false
        } else {
            @Suppress("DEPRECATION")
            val allNetworkInfo = cm.allNetworkInfo ?: return false
            for (info in allNetworkInfo) {
                if (info != null && info.isConnected) {
                    val type = info.type
                    @Suppress("DEPRECATION")
                    if (type == ConnectivityManager.TYPE_WIFI ||
                        type == ConnectivityManager.TYPE_MOBILE ||
                        type == ConnectivityManager.TYPE_ETHERNET
                    ) {
                        return true
                    }
                }
            }
            return false
        }
    }
}
