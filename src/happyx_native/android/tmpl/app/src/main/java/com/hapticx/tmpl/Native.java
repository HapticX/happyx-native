package com.hapticx.tmpl;

public class Native {
    static {
        System.loadLibrary("hpx-native");
    }

    public static native void start();
}
