package com.cliprelay

import android.app.Application
import androidx.appcompat.app.AppCompatDelegate

class ClipRelayApp : Application() {
    override fun onCreate() {
        super.onCreate()
        val prefs = getSharedPreferences(packageName + "_preferences", android.content.Context.MODE_PRIVATE)
        val mode = prefs.getInt("theme_mode", AppCompatDelegate.MODE_NIGHT_NO) // Default to Light Mode
        AppCompatDelegate.setDefaultNightMode(mode)
    }
}
