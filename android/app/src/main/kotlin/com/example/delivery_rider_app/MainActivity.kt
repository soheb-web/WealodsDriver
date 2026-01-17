/*
package com.instantDriver

import android.media.MediaPlayer
import android.media.AudioAttributes
import android.media.AudioManager
import android.content.Context
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.instantDriver/buzzer"
    private var mediaPlayer: MediaPlayer? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "playBuzzer" -> {
                    playAlarmSound()
                    result.success("playing")
                }
                "stopBuzzer" -> {
                    stopAlarmSound()
                    result.success("stopped")
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun playAlarmSound() {
        stopAlarmSound() // pehle rok do agar chal raha ho

        mediaPlayer = MediaPlayer().apply {
            try {
                // assets folder se sound load karo
                val afd = context.assets.openFd("buzzer.mp3")
                setDataSource(afd.fileDescriptor, afd.startOffset, afd.length)
                afd.close()

                // ALARM STREAM + FULL VOLUME FORCE
                setAudioAttributes(
                    AudioAttributes.Builder()
                        .setUsage(AudioAttributes.USAGE_ALARM)
                        .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                        .build()
                )

                val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
                val maxVolume = audioManager.getStreamMaxVolume(AudioManager.STREAM_ALARM)
                audioManager.setStreamVolume(AudioManager.STREAM_ALARM, maxVolume, 0)

                isLooping = true
                prepare()
                start()
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
    }

    private fun stopAlarmSound() {
        mediaPlayer?.stop()
        mediaPlayer?.release()
        mediaPlayer = null
    }

    override fun onDestroy() {
        stopAlarmSound()
        super.onDestroy()
    }
}*/


package com.instantDriver

import android.media.MediaPlayer
import android.media.AudioAttributes
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.instantDriver/buzzer"
    private var mediaPlayer: MediaPlayer? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "playBuzzer" -> {
                        playAlarmSound()
                        result.success("playing")
                    }
                    "stopBuzzer" -> {
                        stopAlarmSound()
                        result.success("stopped")
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun playAlarmSound() {
        stopAlarmSound()

        mediaPlayer = MediaPlayer().apply {
            try {
                val afd = context.assets.openFd("buzzer.mp3")
                setDataSource(afd.fileDescriptor, afd.startOffset, afd.length)
                afd.close()

                // 🔔 Alarm usage rahega
                setAudioAttributes(
                    AudioAttributes.Builder()
                        .setUsage(AudioAttributes.USAGE_ALARM)
                        .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                        .build()
                )

                isLooping = true

                // 🔉 🔉 MAIN FIX — volume control
                // Range: 0.0f (mute) → 1.0f (full)
//                setVolume(0.25f, 0.25f)   // ⭐ 25% volume (best for buzzer)
                setVolume(0.4f, 0.4f)

                prepare()
                start()

            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
    }

    private fun stopAlarmSound() {
        mediaPlayer?.stop()
        mediaPlayer?.release()
        mediaPlayer = null
    }

    override fun onDestroy() {
        stopAlarmSound()
        super.onDestroy()
    }
}
