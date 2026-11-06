package com.am.traffic_tracker_app

import android.app.Activity
import android.content.ContentValues
import android.content.Context
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.media.MediaScannerConnection
import android.net.Uri
import android.net.VpnService
import android.os.Build
import android.os.Environment
import android.os.PowerManager
import android.provider.DocumentsContract
import android.provider.MediaStore
import android.provider.Settings
import android.util.Base64
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream
import java.io.File
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class MainActivity : FlutterActivity() {

    private val VPN_CONTROL_CHANNEL = "traffic_tracker/vpn_control"
    private val VPN_STREAM_CHANNEL = "traffic_tracker/vpn_stream"
    private val VPN_REQUEST_CODE = 0x2468
    private val FOLDER_PICKER_REQUEST_CODE = 0x5432

    private var pendingVpnResult: MethodChannel.Result? = null
    private var pendingAllowedPackages: ArrayList<String>? = null
    private var pendingFolderPickerResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, VPN_CONTROL_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startVpn" -> {
                    if (!NetworkUtils.isNetworkConnected(this)) {
                        result.error("NO_INTERNET", "No active Wi-Fi or Mobile Data connection.", null)
                        return@setMethodCallHandler
                    }

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
                "isNetworkAvailable" -> {
                    result.success(NetworkUtils.isNetworkConnected(this))
                }
                "getPcapPath" -> {
                    result.success(TrafficVpnService.pcapFilePath)
                }
                "updateAllowedPackages" -> {
                    val allowed = call.argument<List<String>>("allowedPackages")
                    pendingAllowedPackages = if (allowed != null) ArrayList(allowed) else null
                    TrafficVpnService.updateAllowedPackages(allowed)
                    result.success(true)
                }
                "getInstalledApps" -> {
                    Thread {
                        val apps = getInstalledAppsList()
                        runOnUiThread { result.success(apps) }
                    }.start()
                }
                "exportPcapFile" -> {
                    val locationType = call.argument<String>("locationType") ?: "downloads"
                    val customUri = call.argument<String>("customUri")
                    Thread {
                        val savedPath = exportPcapInternal(locationType, customUri)
                        runOnUiThread { result.success(savedPath) }
                    }.start()
                }
                "pickDirectory" -> {
                    val intent = Intent(Intent.ACTION_OPEN_DOCUMENT_TREE).apply {
                        addFlags(
                            Intent.FLAG_GRANT_READ_URI_PERMISSION or
                            Intent.FLAG_GRANT_WRITE_URI_PERMISSION or
                            Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION or
                            Intent.FLAG_GRANT_PREFIX_URI_PERMISSION
                        )
                    }
                    pendingFolderPickerResult = result
                    @Suppress("DEPRECATION")
                    startActivityForResult(intent, FOLDER_PICKER_REQUEST_CODE)
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

        // Native Material You / Dynamic Colors Channel (Android 12+)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "traffic_tracker/system_theme").setMethodCallHandler { call, result ->
            when (call.method) {
                "getDynamicAccentColor" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                        try {
                            val colorInt = resources.getColor(android.R.color.system_accent1_600, null)
                            result.success(colorInt)
                        } catch (e: Exception) {
                            result.success(null)
                        }
                    } else {
                        result.success(null)
                    }
                }
                else -> result.notImplemented()
            }
        }

        // Native Battery Optimization Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "traffic_tracker/battery_optimization").setMethodCallHandler { call, result ->
            when (call.method) {
                "isIgnoringBatteryOptimizations" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        val powerManager = getSystemService(Context.POWER_SERVICE) as? PowerManager
                        val isIgnoring = powerManager?.isIgnoringBatteryOptimizations(packageName) ?: false
                        result.success(isIgnoring)
                    } else {
                        // Below Android M, battery optimization (Doze) does not exist
                        result.success(true)
                    }
                }
                "requestIgnoreBatteryOptimization" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        val powerManager = getSystemService(Context.POWER_SERVICE) as? PowerManager
                        val isIgnoring = powerManager?.isIgnoringBatteryOptimizations(packageName) ?: false
                        if (!isIgnoring) {
                            try {
                                val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).apply {
                                    data = Uri.parse("package:$packageName")
                                }
                                startActivity(intent)
                                result.success(true)
                                return@setMethodCallHandler
                            } catch (_: Exception) {
                                // Fallback to settings screen if direct system request fails
                            }
                        }

                        try {
                            val intent = Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS)
                            startActivity(intent)
                            result.success(true)
                        } catch (_: Exception) {
                            try {
                                val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                                    data = Uri.parse("package:$packageName")
                                }
                                startActivity(intent)
                                result.success(true)
                            } catch (e: Exception) {
                                result.error("ACTIVITY_NOT_FOUND", e.message, null)
                            }
                        }
                    } else {
                        result.success(true)
                    }
                }
                else -> result.notImplemented()
            }
        }
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
                if (!NetworkUtils.isNetworkConnected(this)) {
                    pendingVpnResult?.error("NO_INTERNET", "No active Wi-Fi or Mobile Data connection.", null)
                    pendingVpnResult = null
                    return
                }
                startVpnServiceInternal()
                pendingVpnResult?.success(true)
            } else {
                pendingVpnResult?.error("VPN_PERMISSION_DENIED", "User denied VPN permission", null)
            }
            pendingVpnResult = null
        } else if (requestCode == FOLDER_PICKER_REQUEST_CODE) {
            if (resultCode == Activity.RESULT_OK && data?.data != null) {
                val uri = data.data!!
                try {
                    contentResolver.takePersistableUriPermission(
                        uri,
                        Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION
                    )
                } catch (_: Exception) {}

                val docId = try {
                    DocumentsContract.getTreeDocumentId(uri)
                } catch (_: Exception) {
                    uri.lastPathSegment ?: "Custom Folder"
                }
                val displayPath = if (docId.contains(":")) docId.substringAfter(":") else docId
                pendingFolderPickerResult?.success(mapOf(
                    "uri" to uri.toString(),
                    "displayPath" to displayPath
                ))
            } else {
                pendingFolderPickerResult?.success(null)
            }
            pendingFolderPickerResult = null
        }
    }

    private fun exportPcapInternal(locationType: String, customUri: String?): String? {
        TrafficVpnService.flushPcap()

        val prefs = getSharedPreferences("traffic_tracker_prefs", Context.MODE_PRIVATE)
        val savedPath = prefs.getString("last_pcap_path", null)

        var srcFile: File? = if (!TrafficVpnService.pcapFilePath.isNullOrEmpty()) {
            File(TrafficVpnService.pcapFilePath!!)
        } else if (!savedPath.isNullOrEmpty()) {
            File(savedPath)
        } else {
            null
        }

        if (srcFile == null || !srcFile.exists()) {
            // Find most recently modified .pcap file in filesDir
            srcFile = filesDir.listFiles { f -> f.name.endsWith(".pcap") }
                ?.maxByOrNull { it.lastModified() }
        }

        // If no file exists yet, generate a valid initial PCAP capture file
        if (srcFile == null || !srcFile.exists()) {
            val baseline = File(filesDir, "traffic_capture_${System.currentTimeMillis()}.pcap")
            try {
                val fos = java.io.FileOutputStream(baseline)
                val header = java.nio.ByteBuffer.allocate(24).order(java.nio.ByteOrder.LITTLE_ENDIAN)
                header.putInt(0xa1b2c3d4.toInt()) // magic_number
                header.putShort(2.toShort())       // version_major
                header.putShort(4.toShort())       // version_minor
                header.putInt(0)                   // thiszone
                header.putInt(0)                   // sigfigs
                header.putInt(65535)               // snaplen
                header.putInt(12)                  // DLT_RAW (12)
                fos.write(header.array())
                fos.flush()
                fos.fd.sync()
                fos.close()
                srcFile = baseline
                prefs.edit().putString("last_pcap_path", baseline.absolutePath).apply()
            } catch (e: Exception) {
                return null
            }
        }

        val timeStamp = SimpleDateFormat("yyyyMMdd_HHmmss", Locale.US).format(Date())
        val fileName = "traffic_capture_$timeStamp.pcap"

        // 1. Custom SAF Directory (if chosen by user)
        if (locationType == "custom" && !customUri.isNullOrEmpty()) {
            try {
                val treeUri = Uri.parse(customUri)
                val docId = DocumentsContract.getTreeDocumentId(treeUri)
                val dirUri = DocumentsContract.buildDocumentUriUsingTree(treeUri, docId)
                val newDocUri = DocumentsContract.createDocument(
                    contentResolver,
                    dirUri,
                    "application/vnd.tcpdump.pcap",
                    fileName
                )
                if (newDocUri != null) {
                    contentResolver.openOutputStream(newDocUri)?.use { out ->
                        srcFile.inputStream().use { inp ->
                            inp.copyTo(out)
                        }
                    }
                    return fileName
                }
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }

        // 2. MediaStore for Downloads / Documents (Android 10+ / Q+)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val isDocuments = locationType == "documents"
            val collection = if (isDocuments) {
                MediaStore.Files.getContentUri(MediaStore.VOLUME_EXTERNAL_PRIMARY)
            } else {
                MediaStore.Downloads.getContentUri(MediaStore.VOLUME_EXTERNAL_PRIMARY)
            }

            val relativeDir = if (isDocuments) {
                "${Environment.DIRECTORY_DOCUMENTS}/TrafficTracker"
            } else {
                "${Environment.DIRECTORY_DOWNLOADS}/TrafficTracker"
            }

            try {
                val values = ContentValues().apply {
                    put(MediaStore.MediaColumns.DISPLAY_NAME, fileName)
                    put(MediaStore.MediaColumns.MIME_TYPE, "application/vnd.tcpdump.pcap")
                    put(MediaStore.MediaColumns.RELATIVE_PATH, relativeDir)
                }
                val uri = contentResolver.insert(collection, values)
                if (uri != null) {
                    contentResolver.openOutputStream(uri)?.use { out ->
                        srcFile.inputStream().use { inp ->
                            inp.copyTo(out)
                        }
                    }
                    return "$relativeDir/$fileName"
                }
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }

        // 3. Direct File storage fallback
        return try {
            val baseDir = when (locationType) {
                "documents" -> Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOCUMENTS)
                "app_storage" -> getExternalFilesDir(null) ?: filesDir
                else -> Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS)
            }
            val targetFolder = File(baseDir, "TrafficTracker")
            if (!targetFolder.exists()) {
                targetFolder.mkdirs()
            }
            val targetFile = File(targetFolder, fileName)
            srcFile.copyTo(targetFile, overwrite = true)

            MediaScannerConnection.scanFile(
                this,
                arrayOf(targetFile.absolutePath),
                arrayOf("application/vnd.tcpdump.pcap"),
                null
            )
            targetFile.absolutePath
        } catch (e: Exception) {
            e.printStackTrace()
            null
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
