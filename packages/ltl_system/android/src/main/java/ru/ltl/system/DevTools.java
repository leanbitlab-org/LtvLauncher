/*
 * LTvLauncher - ltl_system plugin
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 */

package ru.ltl.system;

import android.content.ActivityNotFoundException;
import android.content.ContentResolver;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Build;
import android.provider.Settings;

import java.lang.reflect.Method;
import java.util.HashMap;
import java.util.Map;

/** ADB, wireless debugging, animation scales and developer options. */
final class DevTools {
    static final String WRITE_SECURE_SETTINGS = "android.permission.WRITE_SECURE_SETTINGS";

    /** Hidden Settings.Global key for wireless debugging (Android 11+). */
    private static final String ADB_WIFI_ENABLED = "adb_wifi_enabled";

    private DevTools() {
    }

    static boolean canWriteSecureSettings(Context ctx) {
        return ctx.checkCallingOrSelfPermission(WRITE_SECURE_SETTINGS) == PackageManager.PERMISSION_GRANTED;
    }

    static Map<String, Object> getAdbStatus(Context ctx) {
        ContentResolver cr = ctx.getContentResolver();
        Map<String, Object> map = new HashMap<>();
        map.put("adbEnabled", readGlobalInt(cr, Settings.Global.ADB_ENABLED, 0) == 1);
        map.put("developerOptionsEnabled",
                readGlobalInt(cr, Settings.Global.DEVELOPMENT_SETTINGS_ENABLED, 0) == 1);
        Boolean wifiAdb = null;
        if (Build.VERSION.SDK_INT >= 30) {
            int value = readGlobalInt(cr, ADB_WIFI_ENABLED, -1);
            if (value >= 0) {
                wifiAdb = value == 1;
            }
        }
        map.put("wifiAdbEnabled", wifiAdb);
        map.put("tcpPort", readTcpPort());
        map.put("canWriteSecureSettings", canWriteSecureSettings(ctx));
        map.put("packageName", ctx.getPackageName());
        map.put("ipAddress", DeviceTools.getIpAddress());
        map.put("sdkInt", Build.VERSION.SDK_INT);
        return map;
    }

    static boolean setAdbEnabled(Context ctx, boolean enabled) {
        if (!canWriteSecureSettings(ctx)) {
            return false;
        }
        try {
            return Settings.Global.putInt(ctx.getContentResolver(), Settings.Global.ADB_ENABLED, enabled ? 1 : 0);
        } catch (SecurityException e) {
            return false;
        }
    }

    static boolean setWifiAdbEnabled(Context ctx, boolean enabled) {
        if (Build.VERSION.SDK_INT < 30 || !canWriteSecureSettings(ctx)) {
            return false;
        }
        try {
            ContentResolver cr = ctx.getContentResolver();
            if (enabled && readGlobalInt(cr, Settings.Global.ADB_ENABLED, 0) != 1) {
                Settings.Global.putInt(cr, Settings.Global.ADB_ENABLED, 1);
            }
            return Settings.Global.putInt(cr, ADB_WIFI_ENABLED, enabled ? 1 : 0);
        } catch (SecurityException e) {
            return false;
        }
    }

    static double getAnimationScale(Context ctx) {
        try {
            return Settings.Global.getFloat(ctx.getContentResolver(), Settings.Global.ANIMATOR_DURATION_SCALE, 1f);
        } catch (Exception e) {
            return 1.0;
        }
    }

    static boolean setAnimationScale(Context ctx, float scale) {
        if (!canWriteSecureSettings(ctx)) {
            return false;
        }
        try {
            ContentResolver cr = ctx.getContentResolver();
            boolean ok = Settings.Global.putFloat(cr, Settings.Global.WINDOW_ANIMATION_SCALE, scale);
            ok &= Settings.Global.putFloat(cr, Settings.Global.TRANSITION_ANIMATION_SCALE, scale);
            ok &= Settings.Global.putFloat(cr, Settings.Global.ANIMATOR_DURATION_SCALE, scale);
            return ok;
        } catch (SecurityException e) {
            return false;
        }
    }

    static boolean openDeveloperSettings(Context ctx) {
        String[] actions = {
                Settings.ACTION_APPLICATION_DEVELOPMENT_SETTINGS,
                Settings.ACTION_DEVICE_INFO_SETTINGS,
                Settings.ACTION_SETTINGS,
        };
        for (String action : actions) {
            try {
                Intent intent = new Intent(action);
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                ctx.startActivity(intent);
                return true;
            } catch (ActivityNotFoundException | SecurityException e) {
                // Try the next screen.
            }
        }
        return false;
    }

    static String getSystemProperty(String key) {
        try {
            Class<?> clazz = Class.forName("android.os.SystemProperties");
            Method get = clazz.getMethod("get", String.class);
            Object value = get.invoke(null, key);
            if (value instanceof String && !((String) value).isEmpty()) {
                return (String) value;
            }
        } catch (Exception ignored) {
            // Not readable on this device.
        }
        return null;
    }

    private static int readGlobalInt(ContentResolver cr, String key, int def) {
        try {
            return Settings.Global.getInt(cr, key, def);
        } catch (Exception e) {
            return def;
        }
    }

    private static Integer readTcpPort() {
        String[] keys = {"service.adb.tcp.port", "persist.adb.tcp.port"};
        for (String key : keys) {
            String value = getSystemProperty(key);
            if (value == null) {
                continue;
            }
            try {
                int port = Integer.parseInt(value.trim());
                if (port > 0) {
                    return port;
                }
            } catch (NumberFormatException ignored) {
                // Ignore malformed values.
            }
        }
        return null;
    }
}
