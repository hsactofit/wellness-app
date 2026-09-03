package com.actofit.arhamsecure

import android.content.Intent
import android.os.Build
import androidx.annotation.NonNull
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    private val channelName = "com.medifit/workout_background"
    private var backgroundChannel: MethodChannel? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        backgroundChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
        backgroundChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "start" -> {
                    if (call.argument<Boolean>("showPersistentTimer") != false) {
                        startWorkoutTimer(call)
                    } else {
                        stopWorkoutTimer()
                    }
                    result.success(null)
                }
                "showTimer" -> {
                    startWorkoutTimer(call)
                    result.success(null)
                }
                "hideTimer" -> {
                    // This hides only the foreground-service notification.
                    // The server session remains open until authenticated
                    // checkout succeeds in Flutter.
                    stopWorkoutTimer()
                    result.success(null)
                }
                "stop" -> {
                    stopWorkoutTimer()
                    result.success(null)
                }
                // iOS queues native events until Flutter has registered its
                // handler. Android does not need a queue, but accepting the
                // shared readiness handshake keeps the bridge quiet and the
                // Dart contract platform-neutral.
                "ready" -> result.success(null)
                else -> result.notImplemented()
            }
        }
        // The foreground-service action can cold-start the activity. Deliver
        // it after the channel is ready just as we do for a warm onNewIntent.
        if (intent?.action == WorkoutForegroundService.ACTION_CHECKOUT) {
            backgroundChannel?.invokeMethod("checkoutRequested", null)
        }
    }

    private fun startWorkoutTimer(call: MethodCall) {
        val intent = Intent(this, WorkoutForegroundService::class.java).apply {
            action = WorkoutForegroundService.ACTION_START
            putExtra("sessionId", call.argument<String>("sessionId"))
            putExtra("facilityName", call.argument<String>("facilityName"))
            putExtra("checkInAt", call.argument<Long>("checkInAt") ?: System.currentTimeMillis())
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(intent)
        } else {
            startService(intent)
        }
    }

    private fun stopWorkoutTimer() {
        stopService(Intent(this, WorkoutForegroundService::class.java))
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        if (intent.action == WorkoutForegroundService.ACTION_CHECKOUT) {
            backgroundChannel?.invokeMethod("checkoutRequested", null)
        }
    }
}
