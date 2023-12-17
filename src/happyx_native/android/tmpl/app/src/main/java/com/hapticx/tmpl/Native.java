package com.hapticx.tmpl;

import android.app.Activity;
import android.content.Context;

import android.os.Handler;


public class Native {
    static {
        System.loadLibrary("hpx-native");
    }

    private final Handler handler = new Handler();
    private final Activity activity;
    private final Runnable runnable = new Runnable() {
        @Override
        public void run() {
            activity.runOnUiThread(() -> runOnUi(activity));
            handler.postDelayed(runnable, 100);
        }
    };

    // need to called from other thread
    public static native void start(Context ctx);
    public static native void runOnUi(Context ctx);

    public Native(Activity activity) {
        this.activity = activity;
    }

    public void uiLoop() {
        handler.post(runnable);
    }
}
