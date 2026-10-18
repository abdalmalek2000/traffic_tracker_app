package com.am.traffic_tracker_app

import android.app.Activity
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.net.VpnService
import android.os.Build
import android.util.Base64
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream

class MainActivity : FlutterActivity() {

    private val VPN_CONTROL_CHANNEL = "traffic_tracker/vpn_control"
    private val VPN_STREAM_CHANNEL = "traffic_tracker/vpn_stream"
    private val VPN_REQUEST_CODE = 0x2468

    private var pendingVpnResult: MethodChannel.Result? = null
    private var pendingAllowedPackages: ArrayList<String>? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, VPN_CONTROL_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startVpn" -> {
                    val allowed = call.argument<List<String>>("allowedPackages")
                    pendingAllowedPackages = if (allowed != null) ArrayList(allowed) else null

                    val vpnIntent = VpnService.prepare(this)
                    if (vpnIntent != null) {
                        pendingVpnResult = result
                        @Suppress("DEPRECATION")
                        startActivityForResult(vpnIntent, VPN_REQUEST_CODE)
                    } else {
                        startVpnServiceInternal()
                        result.success(true)
                    }
                }
                "stopVpn" -> {
                    val intent = Intent(this, TrafficVpnService::class.java).apply {
                        action = TrafficVpnService.ACTION_STOP
                    }
                    startService(intent)
                    result.success(true)
                }
                "isVpnRunning" -> {
                    result.success(TrafficVpnService.isRunning)
                }
                "getPcapPath" -> {
                    result.success(TrafficVpnService.pcapFilePath)
                }
                "getInstalledApps" -> {
                    Thread {
                        val apps = getInstalledAppsList()
                        runOnUiThread { result.success(apps) }
                    }.start()
                }
                else -> result.notImplemented()
            }
        }

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, VPN_STREAM_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    TrafficVpnService.eventSink = events
                }

                override fun onCancel(arguments: Any?) {
                    TrafficVpnService.eventSink = null
                }
            }
        )
    }

    private fun startVpnServiceInternal() {
        val intent = Intent(this, TrafficVpnService::class.java).apply {
            action = TrafficVpnService.ACTION_START
            if (pendingAllowedPackages != null) {
                putStringArrayListExtra(TrafficVpnService.EXTRA_ALLOWED_PACKAGES, pendingAllowedPackages)
            }
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(intent)
        } else {
            startService(intent)
        }
    }

    @Deprecated("Deprecated in Java")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == VPN_REQUEST_CODE) {
            if (resultCode == Activity.RESULT_OK) {
                startVpnServiceInternal()
                pendingVpnResult?.success(true)
            } else {
                pendingVpnResult?.error("VPN_PERMISSION_DENIED", "User denied VPN permission", null)
            }
            pendingVpnResult = null
        }
    }

    private fun getInstalledAppsList(): List<Map<String, Any>> {
        val pm = packageManager
        val packages = pm.getInstalledApplications(PackageManager.GET_META_DATA)
        val appList = mutableListOf<Map<String, Any>>()

        for (appInfo in packages) {
            val isSystem = (appInfo.flags and ApplicationInfo.FLAG_SYSTEM) != 0
            val appName = pm.getApplicationLabel(appInfo).toString()
            val pkgName = appInfo.packageName

            if (pkgName == packageName) continue // Skip our own app

            val iconBase64 = try {
                val drawable = pm.getApplicationIcon(appInfo)
                drawableToBase64(drawable)
            } catch (_: Exception) {
                null
            }

            val appMap = mutableMapOf<String, Any>(
                "appName" to appName,
                "packageName" to pkgName,
                "isSystemApp" to isSystem
            )
            if (iconBase64 != null) {
                appMap["iconBase64"] = iconBase64
            }
            appList.add(appMap)
        }

        // Sort: user apps first, then alphabetically
        appList.sortWith(compareBy({ it["isSystemApp"] as Boolean }, { (it["appName"] as String).lowercase() }))
        return appList
    }

    private fun drawableToBase64(drawable: Drawable): String? {
        val bitmap = if (drawable is BitmapDrawable && drawable.bitmap != null) {
            drawable.bitmap
        } else {
            val width = if (drawable.intrinsicWidth > 0) Math.min(drawable.intrinsicWidth, 72) else 72
            val height = if (drawable.intrinsicHeight > 0) Math.min(drawable.intrinsicHeight, 72) else 72
            val bmp = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
            val canvas = Canvas(bmp)
            drawable.setBounds(0, 0, canvas.width, canvas.height)
            drawable.draw(canvas)
            bmp
        }

        val outputStream = ByteArrayOutputStream()
        bitmap.compress(Bitmap.CompressFormat.PNG, 85, outputStream)
        val byteArray = outputStream.toByteArray()
        return Base64.encodeToString(byteArray, Base64.NO_WRAP)
    }
}
