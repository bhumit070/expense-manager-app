package com.bhumit070.expense_manager

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.location.Location
import android.location.LocationListener
import android.location.LocationManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.view.WindowManager
import androidx.activity.result.ActivityResultLauncher
import androidx.activity.result.contract.ActivityResultContracts
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

// FlutterFragmentActivity is required by local_auth (biometric prompt).
class MainActivity : FlutterFragmentActivity() {
    private var smsResult: MethodChannel.Result? = null

    private val smsPermission: ActivityResultLauncher<String> =
        registerForActivityResult(ActivityResultContracts.RequestPermission()) { granted ->
            smsResult?.success(granted)
            smsResult = null
        }

    private var locationResult: MethodChannel.Result? = null

    private val locationPermission: ActivityResultLauncher<Array<String>> =
        registerForActivityResult(ActivityResultContracts.RequestMultiplePermissions()) { grants ->
            locationResult?.success(grants.values.any { it })
            locationResult = null
        }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Hides app content from the recent-apps switcher and screenshots.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "expense_manager/secure_window").setMethodCallHandler { call, result ->
            when (call.method) {
                "setSecure" -> {
                    if (call.arguments == true) {
                        window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
                    } else {
                        window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                    }
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
        // "Expenses from SMS": the RECEIVE_SMS runtime permission.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "expense_manager/sms").setMethodCallHandler { call, result ->
            when (call.method) {
                "hasPermission" -> result.success(hasSmsPermission())
                "requestPermission" -> {
                    if (hasSmsPermission()) {
                        result.success(true)
                    } else {
                        smsResult?.success(false)
                        smsResult = result
                        smsPermission.launch(Manifest.permission.RECEIVE_SMS)
                    }
                }
                else -> result.notImplemented()
            }
        }
        // Location for transactions, read from the platform LocationManager
        // (no Google Play services, so the app can ship on F-Droid).
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "expense_manager/location").setMethodCallHandler { call, result ->
            when (call.method) {
                "hasPermission" -> result.success(hasLocationPermission())
                "requestPermission" -> {
                    if (hasLocationPermission()) {
                        result.success(true)
                    } else {
                        locationResult?.success(false)
                        locationResult = result
                        locationPermission.launch(arrayOf(Manifest.permission.ACCESS_FINE_LOCATION, Manifest.permission.ACCESS_COARSE_LOCATION))
                    }
                }
                "currentPosition" -> currentPosition(result)
                else -> result.notImplemented()
            }
        }
    }

    private fun hasLocationPermission() =
        listOf(Manifest.permission.ACCESS_FINE_LOCATION, Manifest.permission.ACCESS_COARSE_LOCATION).any {
            ContextCompat.checkSelfPermission(this, it) == PackageManager.PERMISSION_GRANTED
        }

    /// One position fix as {lat, lng}, or null when location is off or unavailable.
    /// Waits up to 6 s for a fresh fix, then falls back to the newest known
    /// position from any provider (the Dart side gives up after 8 s).
    @Suppress("MissingPermission", "DEPRECATION")
    private fun currentPosition(result: MethodChannel.Result) {
        if (!hasLocationPermission()) return result.success(null)
        val manager = getSystemService(Context.LOCATION_SERVICE) as LocationManager
        val enabled = listOfNotNull(
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) LocationManager.FUSED_PROVIDER else null,
            LocationManager.NETWORK_PROVIDER,
            LocationManager.GPS_PROVIDER,
        ).filter { manager.allProviders.contains(it) && manager.isProviderEnabled(it) }
        val provider = enabled.firstOrNull() ?: return result.success(null)
        val handler = Handler(Looper.getMainLooper())
        var answered = false
        fun reply(location: Location?) {
            if (answered) return
            answered = true
            handler.removeCallbacksAndMessages(null)
            val fix = location ?: enabled.mapNotNull { manager.getLastKnownLocation(it) }.maxByOrNull { it.time }
            result.success(fix?.let { mapOf("lat" to it.latitude, "lng" to it.longitude) })
        }
        handler.postDelayed({ reply(null) }, 6000)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            manager.getCurrentLocation(provider, null, mainExecutor) { reply(it) }
        } else {
            manager.requestSingleUpdate(provider, LocationListener { reply(it) }, Looper.getMainLooper())
        }
    }

    private fun hasSmsPermission() =
        ContextCompat.checkSelfPermission(this, Manifest.permission.RECEIVE_SMS) == PackageManager.PERMISSION_GRANTED
}
