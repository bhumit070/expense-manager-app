package com.bhumit070.expense_manager

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.location.Location
import android.location.LocationListener
import android.location.LocationManager
import android.os.Build
import android.os.Bundle
import android.os.CancellationSignal
import android.os.Handler
import android.os.Looper
import android.os.SystemClock
import android.view.WindowManager
import androidx.activity.result.ActivityResultLauncher
import androidx.activity.result.contract.ActivityResultContracts
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/// One in-flight runtime permission request, answered over a method channel.
/// Shared by the SMS and location channels so both handle a repeated request
/// and the Activity going away the same way.
private class PendingPermission(private val isGranted: () -> Boolean) {
    private var result: MethodChannel.Result? = null

    fun start(result: MethodChannel.Result, launch: () -> Unit) {
        if (isGranted()) return result.success(true)
        finish() // a newer request replaces an older one
        this.result = result
        launch()
    }

    /// Answers the pending request (if any) with the current permission state.
    fun finish() {
        result?.success(isGranted())
        result = null
    }
}

// FlutterFragmentActivity is required by local_auth (biometric prompt).
class MainActivity : FlutterFragmentActivity() {
    private val sms = PendingPermission(::hasSmsPermission)
    private val smsLauncher: ActivityResultLauncher<String> =
        registerForActivityResult(ActivityResultContracts.RequestPermission()) { sms.finish() }

    private val location = PendingPermission(::hasLocationPermission)
    private val locationLauncher: ActivityResultLauncher<Array<String>> =
        registerForActivityResult(ActivityResultContracts.RequestMultiplePermissions()) { location.finish() }

    /// Stops the location requests still running, keyed by request.
    private val activeFixes = mutableSetOf<Runnable>()

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
                "requestPermission" -> sms.start(result) { smsLauncher.launch(Manifest.permission.RECEIVE_SMS) }
                else -> result.notImplemented()
            }
        }
        // Location for transactions, read from the platform LocationManager
        // (no Google Play services, so the app can ship on F-Droid).
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "expense_manager/location").setMethodCallHandler { call, result ->
            when (call.method) {
                "hasPermission" -> result.success(hasLocationPermission())
                "requestPermission" -> location.start(result) {
                    locationLauncher.launch(arrayOf(Manifest.permission.ACCESS_FINE_LOCATION, Manifest.permission.ACCESS_COARSE_LOCATION))
                }
                "currentPosition" -> currentPosition(call, result)
                else -> result.notImplemented()
            }
        }
    }

    override fun onDestroy() {
        // Never leave a Dart future waiting on an Activity that is gone, and
        // never leave GPS running for it.
        sms.finish()
        location.finish()
        activeFixes.toList().forEach { it.run() }
        activeFixes.clear()
        super.onDestroy()
    }

    private fun granted(permission: String) =
        ContextCompat.checkSelfPermission(this, permission) == PackageManager.PERMISSION_GRANTED

    private fun hasLocationPermission() =
        granted(Manifest.permission.ACCESS_FINE_LOCATION) || granted(Manifest.permission.ACCESS_COARSE_LOCATION)

    /// One position fix as {lat, lng, accuracy, time}, or null when location
    /// is off or unavailable.
    ///
    /// Arguments (from AndroidLocation in lib/services/location.dart):
    /// - waitMs: how long to wait for a fresh fix before falling back.
    /// - maxAgeMs: the oldest last-known position the fallback may return.
    /// - precise: false skips GPS when another provider is available.
    ///
    /// Every enabled provider is asked at once and the first fix wins, so an
    /// offline phone still gets GPS. All requests are cancelled on reply.
    @Suppress("MissingPermission", "DEPRECATION")
    private fun currentPosition(call: MethodCall, result: MethodChannel.Result) {
        if (!hasLocationPermission()) return result.success(null)
        val waitMs = call.argument<Number>("waitMs")?.toLong() ?: 6000L
        val maxAgeMs = call.argument<Number>("maxAgeMs")?.toLong() ?: 10 * 60 * 1000L
        val precise = call.argument<Boolean>("precise") ?: true
        val manager = getSystemService(Context.LOCATION_SERVICE) as LocationManager

        val enabled = listOfNotNull(
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) LocationManager.FUSED_PROVIDER else null,
            LocationManager.GPS_PROVIDER,
            LocationManager.NETWORK_PROVIDER,
        ).filter {
            runCatching { manager.allProviders.contains(it) && manager.isProviderEnabled(it) }.getOrDefault(false)
        }
        // GPS needs FINE; with only "approximate" location granted it throws.
        val usable = if (granted(Manifest.permission.ACCESS_FINE_LOCATION)) enabled else enabled - LocationManager.GPS_PROVIDER
        val providers = if (!precise && usable.any { it != LocationManager.GPS_PROVIDER }) usable - LocationManager.GPS_PROVIDER else usable
        if (providers.isEmpty()) return result.success(null)

        val handler = Handler(Looper.getMainLooper())
        val cancels = mutableListOf<() -> Unit>()
        var answered = false
        var waiting = providers.size
        lateinit var stop: Runnable

        fun reply(fix: Location?) {
            if (answered) return
            answered = true
            activeFixes.remove(stop)
            stop.run()
            val best = fix ?: lastKnown(manager, providers, maxAgeMs)
            result.success(
                best?.let { mapOf("lat" to it.latitude, "lng" to it.longitude, "accuracy" to it.accuracy.toDouble(), "time" to it.time) },
            )
        }

        // A provider finished without a fix; once all have, stop waiting.
        fun failed() {
            if (--waiting <= 0) reply(null)
        }

        stop = Runnable {
            handler.removeCallbacksAndMessages(null)
            cancels.forEach { runCatching(it) }
            cancels.clear()
        }
        activeFixes.add(stop)
        handler.postDelayed({ reply(null) }, waitMs)

        for (provider in providers) {
            try {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                    val signal = CancellationSignal()
                    cancels += { signal.cancel() }
                    manager.getCurrentLocation(provider, signal, mainExecutor) { fix ->
                        if (fix != null) reply(fix) else failed()
                    }
                } else {
                    // Implement every method: before API 30 the other three
                    // have no default, so a lambda would crash when called.
                    val listener = object : LocationListener {
                        override fun onLocationChanged(fix: Location) = reply(fix)
                        override fun onStatusChanged(provider: String?, status: Int, extras: Bundle?) {}
                        override fun onProviderEnabled(provider: String) {}
                        override fun onProviderDisabled(provider: String) = failed()
                    }
                    cancels += { manager.removeUpdates(listener) }
                    manager.requestSingleUpdate(provider, listener, Looper.getMainLooper())
                }
            } catch (e: RuntimeException) {
                // SecurityException / IllegalArgumentException for this provider.
                failed()
            }
        }
    }

    /// The newest last-known position no older than [maxAgeMs], if any.
    @Suppress("MissingPermission")
    private fun lastKnown(manager: LocationManager, providers: List<String>, maxAgeMs: Long): Location? {
        val now = SystemClock.elapsedRealtimeNanos()
        return providers
            .mapNotNull { runCatching { manager.getLastKnownLocation(it) }.getOrNull() }
            .filter { (now - it.elapsedRealtimeNanos) / 1_000_000 <= maxAgeMs }
            .maxByOrNull { it.elapsedRealtimeNanos }
    }

    private fun hasSmsPermission() = granted(Manifest.permission.RECEIVE_SMS)
}
