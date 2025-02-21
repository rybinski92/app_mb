package com.a10i.app_kb 

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "config"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)


        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getApiKey1" -> result.success(BuildConfig.API_KEY1)
                "getApiKey2" -> result.success(BuildConfig.API_KEY2)
                "getApiKey3" -> result.success(BuildConfig.API_KEY3)
                "getApiKey4" -> result.success(BuildConfig.API_KEY4)
                else -> result.notImplemented()
            }
        }
    }
}
