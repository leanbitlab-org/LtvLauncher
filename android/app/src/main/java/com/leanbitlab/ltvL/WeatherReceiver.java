package com.leanbitlab.ltvL;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;

public class WeatherReceiver extends BroadcastReceiver {
    public static final String ACTION_GENERIC_WEATHER = "nodomain.freeyourgadget.gadgetbridge.ACTION_GENERIC_WEATHER";
    public static final String ACTION_BREEZY_UPDATE_NOTIFIER = "org.breezyweather.ACTION_UPDATE_NOTIFIER";
    public static final String ACTION_BREEZY_UPDATE_NOTIFIER_DEBUG = "org.breezyweather.debug.ACTION_UPDATE_NOTIFIER";
    public static final String PREFS_NAME = "lwidget_breezy_weather_data";
    public static final String KEY_WEATHER_JSON = "weather_json";

    public interface WeatherListener {
        void onWeatherUpdated(String weatherJson);
    }

    private static WeatherListener sListener;

    public static void setListener(WeatherListener listener) {
        sListener = listener;
    }

    @Override
    public void onReceive(Context context, Intent intent) {
        if (intent == null) return;
        String action = intent.getAction();
        if (ACTION_GENERIC_WEATHER.equals(action)) {
            String weatherJson = intent.getStringExtra("WeatherJson");
            if (weatherJson != null && !weatherJson.isEmpty()) {
                SharedPreferences prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE);
                prefs.edit().putString(KEY_WEATHER_JSON, weatherJson).apply();
                if (sListener != null) {
                    sListener.onWeatherUpdated(weatherJson);
                }
            }
        } else if (ACTION_BREEZY_UPDATE_NOTIFIER.equals(action) || ACTION_BREEZY_UPDATE_NOTIFIER_DEBUG.equals(action)) {
            String weatherJson = intent.getStringExtra("WeatherJson");
            if (weatherJson != null && !weatherJson.isEmpty()) {
                SharedPreferences prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE);
                prefs.edit().putString(KEY_WEATHER_JSON, weatherJson).apply();
                if (sListener != null) {
                    sListener.onWeatherUpdated(weatherJson);
                }
            } else {
                SharedPreferences prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE);
                String current = prefs.getString(KEY_WEATHER_JSON, null);
                if (sListener != null && current != null) {
                    sListener.onWeatherUpdated(current);
                }
            }
        }
    }
}
