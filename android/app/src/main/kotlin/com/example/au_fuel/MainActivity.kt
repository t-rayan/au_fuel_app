package com.example.au_fuel

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.au_fuel/car"

    companion object {
        // Shared data storage that the Car App Service can access
        var stationsData: List<Map<String, Any>> = emptyList()
        var onDataUpdated: (() -> Unit)? = null
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "updateStations") {
                val data = call.arguments as? List<Map<String, Any>>
                if (data != null) {
                    stationsData = data
                    onDataUpdated?.invoke() // Notify the Car Service to refresh its screen
                    result.success(true)
                } else {
                    result.error("INVALID_DATA", "Data was not a list of maps", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
