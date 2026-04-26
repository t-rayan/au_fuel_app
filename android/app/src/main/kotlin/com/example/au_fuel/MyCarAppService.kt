package com.example.au_fuel

import android.content.Intent
import androidx.car.app.CarAppService
import androidx.car.app.Session
import androidx.car.app.Screen
import androidx.car.app.model.*
import androidx.car.app.validation.HostValidator
import androidx.car.app.CarContext

class MyCarAppService : CarAppService() {
    override fun createHostValidator(): HostValidator = HostValidator.ALLOW_ALL_HOSTS_VALIDATOR
    override fun onCreateSession(): Session = FuelAppSession()
}

class FuelAppSession : Session() {
    private var currentScreen: Screen? = null

    override fun onCreateScreen(intent: Intent): Screen {
        val screen = FuelListScreen(carContext)
        currentScreen = screen

        MainActivity.onDataUpdated = {
            try {
                currentScreen?.invalidate()
            } catch (e: Exception) {
                // Ignore if screen is gone
            }
        }

        return screen
    }
}

class FuelListScreen(carContext: CarContext) : Screen(carContext) {
    override fun onGetTemplate(): Template {
        val listBuilder = ItemList.Builder()
            .setNoItemsMessage("Open the app on your phone to see nearby fuel prices.")

        // Build items from the live data bridge
        MainActivity.stationsData.take(12).forEach { data ->
            val name = data["name"] as? String ?: "Unknown Station"
            val price = data["price"] as? Double ?: 0.0
            val formattedPrice = String.format("$%.2f", price / 1000)

            listBuilder.addItem(
                Row.Builder()
                    .setTitle(name)
                    .addText("Price: $formattedPrice")
                    .build()
            )
        }

        // ListTemplate: The most stable and reliable template for development
        return ListTemplate.Builder()
            .setTitle("Nearby Fuel")
            .setSingleList(listBuilder.build())
            .setHeaderAction(Action.APP_ICON)
            .build()
    }
}
