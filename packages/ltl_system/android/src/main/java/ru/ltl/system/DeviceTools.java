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
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Build;

import java.net.Inet4Address;
import java.net.InetAddress;
import java.net.NetworkInterface;
import java.util.Collections;
import java.util.HashMap;
import java.util.Locale;
import java.util.Map;

/** Device information, YaOS detection, network address and links. */
final class DeviceTools {
    private static final String[] YAOS_PACKAGES = {
            "com.yandex.tv.home",
            "com.yandex.tv.services",
            "ru.yandex.quasar.app",
    };

    private DeviceTools() {
    }

    static Map<String, Object> getDeviceInfo(Context ctx) {
        Map<String, Object> map = new HashMap<>();
        map.put("manufacturer", Build.MANUFACTURER);
        map.put("brand", Build.BRAND);
        map.put("model", Build.MODEL);
        map.put("androidVersion", Build.VERSION.RELEASE);
        map.put("sdkInt", Build.VERSION.SDK_INT);
        map.put("buildId", Build.DISPLAY);
        map.put("isYaOs", isYaOs(ctx));
        map.put("ipAddress", getIpAddress());
        return map;
    }

    /** Best-effort detection of Yandex TV OS (YaOS). */
    static boolean isYaOs(Context ctx) {
        String build = (Build.FINGERPRINT + " " + Build.DISPLAY + " " + Build.PRODUCT + " " + Build.BRAND)
                .toLowerCase(Locale.ROOT);
        if (build.contains("yandex") || build.contains("yaos")) {
            return true;
        }
        PackageManager pm = ctx.getPackageManager();
        for (String pkg : YAOS_PACKAGES) {
            try {
                pm.getPackageInfo(pkg, 0);
                return true;
            } catch (PackageManager.NameNotFoundException ignored) {
                // Not installed.
            }
        }
        return false;
    }

    /** IPv4 address of the active Wi-Fi/Ethernet interface, or null. */
    static String getIpAddress() {
        try {
            String fallback = null;
            for (NetworkInterface nif : Collections.list(NetworkInterface.getNetworkInterfaces())) {
                if (!nif.isUp() || nif.isLoopback()) {
                    continue;
                }
                for (InetAddress address : Collections.list(nif.getInetAddresses())) {
                    if (!(address instanceof Inet4Address) || address.isLoopbackAddress()) {
                        continue;
                    }
                    String host = address.getHostAddress();
                    String name = nif.getName();
                    if (name != null && (name.startsWith("wlan") || name.startsWith("eth"))) {
                        return host;
                    }
                    if (fallback == null) {
                        fallback = host;
                    }
                }
            }
            return fallback;
        } catch (Exception e) {
            return null;
        }
    }

    static boolean openUrl(Context ctx, String url) {
        if (url == null || url.trim().isEmpty()) {
            return false;
        }
        Intent intent = new Intent(Intent.ACTION_VIEW, Uri.parse(url.trim()));
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        try {
            ctx.startActivity(intent);
            return true;
        } catch (ActivityNotFoundException | SecurityException e) {
            return false;
        }
    }
}
