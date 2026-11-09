/*
 * LTvLauncher - ltl_system plugin
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 */

package ru.ltl.system;

import android.content.Context;
import android.os.Handler;
import android.os.Looper;

import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

/**
 * Entry point of the ltl_system plugin.
 *
 * Calls that start activities run on the main thread, everything else runs on
 * a single background thread so slow system services never block the UI.
 */
public class LtlSystemPlugin implements FlutterPlugin, MethodChannel.MethodCallHandler {
    private static final String CHANNEL = "ru.ltl.system/methods";

    private final Handler mainHandler = new Handler(Looper.getMainLooper());
    private MethodChannel channel;
    private Context context;
    private ExecutorService executor;

    @Override
    public void onAttachedToEngine(FlutterPluginBinding binding) {
        context = binding.getApplicationContext();
        executor = Executors.newSingleThreadExecutor();
        channel = new MethodChannel(binding.getBinaryMessenger(), CHANNEL);
        channel.setMethodCallHandler(this);
    }

    @Override
    public void onDetachedFromEngine(FlutterPluginBinding binding) {
        if (channel != null) {
            channel.setMethodCallHandler(null);
            channel = null;
        }
        if (executor != null) {
            executor.shutdown();
            executor = null;
        }
        context = null;
    }

    @Override
    public void onMethodCall(MethodCall call, MethodChannel.Result result) {
        final Context ctx = context;
        final ExecutorService ex = executor;
        if (ctx == null || ex == null) {
            result.error("detached", "ltl_system is not attached to an engine", null);
            return;
        }

        // Activities are started from the main thread.
        switch (call.method) {
            case "openDeveloperSettings":
                result.success(DevTools.openDeveloperSettings(ctx));
                return;
            case "openUrl":
                result.success(DeviceTools.openUrl(ctx, call.<String>argument("url")));
                return;
            default:
                break;
        }

        ex.execute(() -> {
            final Object value;
            try {
                value = handleInBackground(ctx, call);
            } catch (UnsupportedOperationException e) {
                mainHandler.post(result::notImplemented);
                return;
            } catch (Exception e) {
                final String message = e.getClass().getSimpleName() + ": " + e.getMessage();
                mainHandler.post(() -> result.error("ltl_error", message, null));
                return;
            }
            mainHandler.post(() -> result.success(value));
        });
    }

    private static Object handleInBackground(Context ctx, MethodCall call) {
        switch (call.method) {
            case "getAdbStatus":
                return DevTools.getAdbStatus(ctx);
            case "setAdbEnabled":
                return DevTools.setAdbEnabled(ctx, Boolean.TRUE.equals(call.argument("enabled")));
            case "setWifiAdbEnabled":
                return DevTools.setWifiAdbEnabled(ctx, Boolean.TRUE.equals(call.argument("enabled")));
            case "getAnimationScale":
                return DevTools.getAnimationScale(ctx);
            case "setAnimationScale": {
                Number scale = call.argument("scale");
                return DevTools.setAnimationScale(ctx, scale == null ? 1f : scale.floatValue());
            }
            case "getDeviceInfo":
                return DeviceTools.getDeviceInfo(ctx);
            default:
                throw new UnsupportedOperationException(call.method);
        }
    }
}
