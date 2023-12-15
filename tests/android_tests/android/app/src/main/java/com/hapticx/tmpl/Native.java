package com.hapticx.tmpl;

import android.content.Context;


public class Native {
    static {
        System.loadLibrary("hpx-native");
    }

    // need to called from other thread
    public static native void start(Context ctx);
}
