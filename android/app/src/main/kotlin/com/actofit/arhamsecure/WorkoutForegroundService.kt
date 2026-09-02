package com.actofit.arhamsecure

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Intent
import android.os.Build
import android.os.IBinder

/**
 * Keeps an active workout visible while Flutter is backgrounded.  The
 * chronometer is driven by Android's notification framework, so it remains
 * accurate after the Dart isolate is paused or the screen is locked.
 */
class WorkoutForegroundService : Service() {
    companion object {
        const val ACTION_START = "com.medifit.workout.START"
        const val ACTION_STOP = "com.medifit.workout.STOP"
        const val ACTION_CHECKOUT = "com.medifit.workout.CHECKOUT"
        private const val CHANNEL_ID = "active_workout"
        private const val NOTIFICATION_ID = 4201
    }

    override fun onCreate() {
        super.onCreate()
        val manager = getSystemService(NotificationManager::class.java)
        manager.createNotificationChannel(
            NotificationChannel(
                CHANNEL_ID,
                "Active workout",
                NotificationManager.IMPORTANCE_LOW,
            ).apply {
                description = "Shows the active Medifit workout timer"
                setShowBadge(false)
            },
        )
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent?.action == ACTION_STOP) {
            stopForeground(STOP_FOREGROUND_REMOVE)
            stopSelf()
            return START_NOT_STICKY
        }

        val checkInAt = intent?.getLongExtra("checkInAt", System.currentTimeMillis())
            ?: System.currentTimeMillis()
        val facilityName = intent?.getStringExtra("facilityName") ?: "Medifit facility"
        val checkoutIntent = Intent(this, MainActivity::class.java).apply {
            action = ACTION_CHECKOUT
            this.flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        val checkoutPendingIntent = PendingIntent.getActivity(
            this,
            4202,
            checkoutIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        val builder = Notification.Builder(this, CHANNEL_ID)
            .setSmallIcon(android.R.drawable.ic_menu_myplaces)
            .setContentTitle("Workout in progress")
            .setContentText(facilityName)
            .setWhen(checkInAt)
            .setUsesChronometer(true)
            .setOngoing(true)
            .setCategory(Notification.CATEGORY_WORKOUT)
            .setContentIntent(checkoutPendingIntent)
            .addAction(
                Notification.Action.Builder(
                    android.graphics.drawable.Icon.createWithResource(this, android.R.drawable.ic_menu_close_clear_cancel),
                    "Checkout",
                    checkoutPendingIntent,
                ).build(),
            )

        startForeground(NOTIFICATION_ID, builder.build())
        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null
}
