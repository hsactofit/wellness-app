package com.actofit.arhamsecure

import android.Manifest
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.location.Location
import android.location.LocationListener
import android.location.LocationManager
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import androidx.core.content.ContextCompat
import kotlin.math.atan2
import kotlin.math.cos
import kotlin.math.sin
import kotlin.math.sqrt

/**
 * Owns Android's active-workout notification, hourly confirmation prompts and
 * local-only scanner-origin exit check. The sole origin point is erased at
 * checkout; no location history is written or sent to the API.
 */
class WorkoutForegroundService : Service(), LocationListener {
    companion object {
        const val ACTION_START = "com.medifit.workout.START"
        const val ACTION_STOP = "com.medifit.workout.STOP"
        const val ACTION_CHECKOUT = "com.medifit.workout.CHECKOUT"
        const val ACTION_ARM_SCANNER_ORIGIN = "com.medifit.workout.ARM_SCANNER_ORIGIN"
        const val ACTION_HOURLY_CONTINUE = "com.medifit.workout.HOURLY_CONTINUE"
        private const val TIMER_CHANNEL_ID = "active_workout"
        private const val PROMPT_CHANNEL_ID = "active_workout_prompts"
        private const val NOTIFICATION_ID = 4201
        private const val HOURLY_NOTIFICATION_ID = 4203
        private const val DEPARTURE_NOTIFICATION_ID = 4204
        private const val PREFS = "medifit_workout_background"
        private const val ORIGIN_RADIUS_METERS = 2000.0
    }

    private val handler = Handler(Looper.getMainLooper())
    private lateinit var locationManager: LocationManager
    private var hourlyRunnable: Runnable? = null
    private var slotEndRunnable: Runnable? = null

    override fun onCreate() {
        super.onCreate()
        locationManager = getSystemService(Context.LOCATION_SERVICE) as LocationManager
        val manager = getSystemService(NotificationManager::class.java)
        manager.createNotificationChannel(
            NotificationChannel(TIMER_CHANNEL_ID, "Active workout", NotificationManager.IMPORTANCE_LOW).apply {
                description = "Shows the active Medifit workout timer"
                setShowBadge(false)
            },
        )
        manager.createNotificationChannel(
            NotificationChannel(PROMPT_CHANNEL_ID, "Workout confirmations", NotificationManager.IMPORTANCE_HIGH).apply {
                description = "Asks whether an active workout is still in progress"
                setShowBadge(false)
            },
        )
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent?.action == ACTION_STOP) {
            clearWorkout()
            stopForeground(STOP_FOREGROUND_REMOVE)
            stopSelf()
            return START_NOT_STICKY
        }
        when (intent?.action) {
            ACTION_START -> saveWorkout(intent)
            ACTION_ARM_SCANNER_ORIGIN -> armScannerOrigin(intent)
            ACTION_HOURLY_CONTINUE -> confirmHourlyContinuation()
        }
        val prefs = prefs()
        if (!prefs.getBoolean("active", false)) return START_NOT_STICKY
        startForeground(NOTIFICATION_ID, timerNotification())
        scheduleHourlyPrompt()
        scheduleSlotEndPrompt()
        requestLocationUpdatesIfPermitted()
        return START_REDELIVER_INTENT
    }

    private fun prefs() = getSharedPreferences(PREFS, Context.MODE_PRIVATE)

    private fun saveWorkout(intent: Intent) {
        val sessionId = intent.getStringExtra("sessionId") ?: return
        val shared = prefs()
        val sessionChanged = shared.getString("session_id", null) != sessionId
        val editor = shared.edit()
            .putBoolean("active", true)
            .putString("session_id", sessionId)
            .putString("facility_name", intent.getStringExtra("facilityName") ?: "Medifit facility")
            .putLong("check_in_at", intent.getLongExtra("checkInAt", System.currentTimeMillis()))
        if (intent.hasExtra("slotEndAt")) editor.putLong("slot_end_at", intent.getLongExtra("slotEndAt", 0L))
        if (sessionChanged) {
            editor.remove("origin_latitude")
            editor.remove("origin_longitude")
            editor.remove("departure_prompted")
            editor.remove("next_hourly_at")
        }
        editor.apply()
    }

    private fun armScannerOrigin(intent: Intent) {
        val shared = prefs()
        val sessionId = intent.getStringExtra("sessionId") ?: return
        if (!shared.getBoolean("active", false) || shared.getString("session_id", null) != sessionId) return
        shared.edit()
            .putString("origin_latitude", intent.getDoubleExtra("latitude", 0.0).toString())
            .putString("origin_longitude", intent.getDoubleExtra("longitude", 0.0).toString())
            .putBoolean("departure_prompted", false)
            .apply()
    }

    private fun confirmHourlyContinuation() {
        prefs().edit().putLong("next_hourly_at", System.currentTimeMillis() + 60 * 60 * 1000L).apply()
        getSystemService(NotificationManager::class.java).cancel(HOURLY_NOTIFICATION_ID)
        scheduleHourlyPrompt()
    }

    private fun scheduleHourlyPrompt() {
        hourlyRunnable?.let(handler::removeCallbacks)
        val shared = prefs()
        if (!shared.getBoolean("active", false)) return
        val next = shared.getLong("next_hourly_at", 0L).let {
            if (it > System.currentTimeMillis()) it else System.currentTimeMillis() + 60 * 60 * 1000L
        }
        shared.edit().putLong("next_hourly_at", next).apply()
        hourlyRunnable = Runnable {
            showHourlyPrompt()
            // Ignore/dismiss intentionally does not count as a yes; the next
            // confirmation is one hour after this unanswered prompt.
            shared.edit().putLong("next_hourly_at", System.currentTimeMillis() + 60 * 60 * 1000L).apply()
            scheduleHourlyPrompt()
        }
        handler.postDelayed(hourlyRunnable!!, (next - System.currentTimeMillis()).coerceAtLeast(1L))
    }

    private fun scheduleSlotEndPrompt() {
        slotEndRunnable?.let(handler::removeCallbacks)
        val shared = prefs()
        val slotEnd = shared.getLong("slot_end_at", 0L)
        val hourly = shared.getLong("next_hourly_at", 0L)
        if (slotEnd <= System.currentTimeMillis() || kotlin.math.abs(slotEnd - hourly) <= 10 * 60 * 1000L) return
        slotEndRunnable = Runnable { showSlotEndPrompt() }
        handler.postDelayed(slotEndRunnable!!, slotEnd - System.currentTimeMillis())
    }

    private fun requestLocationUpdatesIfPermitted() {
        val shared = prefs()
        if (!shared.contains("origin_latitude") || !hasLocationPermission()) return
        try {
            locationManager.removeUpdates(this)
            locationManager.requestLocationUpdates(LocationManager.GPS_PROVIDER, 60_000L, 50f, this, Looper.getMainLooper())
            locationManager.requestLocationUpdates(LocationManager.NETWORK_PROVIDER, 60_000L, 50f, this, Looper.getMainLooper())
        } catch (_: SecurityException) {
            // The active workout and manual checkout continue if permission changes.
        } catch (_: IllegalArgumentException) {
            // Some devices do not provide every location provider.
        }
    }

    private fun hasLocationPermission(): Boolean =
        ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED ||
            ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_COARSE_LOCATION) == PackageManager.PERMISSION_GRANTED

    override fun onLocationChanged(location: Location) {
        val shared = prefs()
        if (!shared.getBoolean("active", false) || shared.getBoolean("departure_prompted", false)) return
        if (!shared.contains("origin_latitude") || !shared.contains("origin_longitude")) return
        val distance = distanceMeters(
            shared.getString("origin_latitude", null)?.toDoubleOrNull() ?: return,
            shared.getString("origin_longitude", null)?.toDoubleOrNull() ?: return,
            location.latitude,
            location.longitude,
        )
        if (distance >= ORIGIN_RADIUS_METERS) {
            shared.edit().putBoolean("departure_prompted", true).apply()
            showDeparturePrompt()
        }
    }

    private fun timerNotification(): Notification {
        val shared = prefs()
        val checkout = checkoutPendingIntent()
        return Notification.Builder(this, TIMER_CHANNEL_ID)
            .setSmallIcon(android.R.drawable.ic_menu_myplaces)
            .setContentTitle("Workout in progress")
            .setContentText(shared.getString("facility_name", "Medifit facility"))
            .setWhen(shared.getLong("check_in_at", System.currentTimeMillis()))
            .setUsesChronometer(true)
            .setOngoing(true)
            .setAutoCancel(false)
            .setOnlyAlertOnce(true)
            .setCategory(Notification.CATEGORY_WORKOUT)
            .setContentIntent(checkout)
            .addAction(action("Checkout", checkout))
            .build()
    }

    private fun showHourlyPrompt() {
        val keepWorking = PendingIntent.getService(
            this,
            4205,
            Intent(this, WorkoutForegroundService::class.java).setAction(ACTION_HOURLY_CONTINUE),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        val notification = Notification.Builder(this, PROMPT_CHANNEL_ID)
            .setSmallIcon(android.R.drawable.ic_popup_reminder)
            .setContentTitle("Are you still working out?")
            .setContentText("Confirm to keep the timer running, or open checkout when you are done.")
            .setPriority(Notification.PRIORITY_HIGH)
            .setAutoCancel(true)
            .setContentIntent(checkoutPendingIntent())
            .addAction(action("Yes, still working", keepWorking))
            .addAction(action("No, open checkout", checkoutPendingIntent()))
            .build()
        getSystemService(NotificationManager::class.java).notify(HOURLY_NOTIFICATION_ID, notification)
    }

    private fun showSlotEndPrompt() {
        val keepWorking = PendingIntent.getService(
            this,
            4206,
            Intent(this, WorkoutForegroundService::class.java).setAction(ACTION_HOURLY_CONTINUE),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        val notification = Notification.Builder(this, PROMPT_CHANNEL_ID)
            .setSmallIcon(android.R.drawable.ic_popup_reminder)
            .setContentTitle("Your booked slot has ended")
            .setContentText("Open checkout when you are done, or confirm that you are still working out.")
            .setPriority(Notification.PRIORITY_HIGH)
            .setAutoCancel(true)
            .setContentIntent(checkoutPendingIntent())
            .addAction(action("Still working", keepWorking))
            .addAction(action("Open checkout", checkoutPendingIntent()))
            .build()
        getSystemService(NotificationManager::class.java).notify(HOURLY_NOTIFICATION_ID, notification)
    }

    private fun showDeparturePrompt() {
        val checkout = checkoutPendingIntent()
        val notification = Notification.Builder(this, PROMPT_CHANNEL_ID)
            .setSmallIcon(android.R.drawable.ic_dialog_alert)
            .setContentTitle("Have you left your workout?")
            .setContentText("Your phone is 2 km from where you scanned in. Please open checkout to finish the active session.")
            .setPriority(Notification.PRIORITY_HIGH)
            .setAutoCancel(true)
            .setContentIntent(checkout)
            // No continue action after a scanner-origin departure.
            .addAction(action("Yes, open checkout", checkout))
            .build()
        getSystemService(NotificationManager::class.java).notify(DEPARTURE_NOTIFICATION_ID, notification)
    }

    private fun checkoutPendingIntent(): PendingIntent = PendingIntent.getActivity(
        this,
        4202,
        Intent(this, MainActivity::class.java).apply {
            action = ACTION_CHECKOUT
            flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP
        },
        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
    )

    private fun action(label: String, pendingIntent: PendingIntent): Notification.Action =
        Notification.Action.Builder(
            android.graphics.drawable.Icon.createWithResource(this, android.R.drawable.ic_menu_close_clear_cancel),
            label,
            pendingIntent,
        ).build()

    private fun distanceMeters(lat1: Double, lon1: Double, lat2: Double, lon2: Double): Double {
        val earthRadius = 6_371_000.0
        val deltaLatitude = Math.toRadians(lat2 - lat1)
        val deltaLongitude = Math.toRadians(lon2 - lon1)
        val a = sin(deltaLatitude / 2) * sin(deltaLatitude / 2) +
            cos(Math.toRadians(lat1)) * cos(Math.toRadians(lat2)) *
                sin(deltaLongitude / 2) * sin(deltaLongitude / 2)
        return earthRadius * 2 * atan2(sqrt(a), sqrt(1 - a))
    }

    private fun clearWorkout() {
        hourlyRunnable?.let(handler::removeCallbacks)
        slotEndRunnable?.let(handler::removeCallbacks)
        try { locationManager.removeUpdates(this) } catch (_: SecurityException) {}
        prefs().edit().clear().apply()
        getSystemService(NotificationManager::class.java).cancel(HOURLY_NOTIFICATION_ID)
        getSystemService(NotificationManager::class.java).cancel(DEPARTURE_NOTIFICATION_ID)
    }

    override fun onDestroy() {
        hourlyRunnable?.let(handler::removeCallbacks)
        slotEndRunnable?.let(handler::removeCallbacks)
        try { locationManager.removeUpdates(this) } catch (_: SecurityException) {}
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null
}
