package com.hapticx.tmpl;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.os.Bundle;
import android.webkit.WebChromeClient;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;

public class MainActivity extends Activity {
    private WebView w;
    private boolean paused = false;

    @SuppressLint("SetJavaScriptEnabled")
    @Override
    protected void onCreate(Bundle s) {
        super.onCreate(s);
        setContentView(R.layout.activity_main);

        w = findViewById(R.id.webView);

        if (!paused) {
            new Thread(() -> Native.start(this)).start();

            Native n = new Native(this);
            n.uiLoop();
        }
        setupWebView();
    }

    @SuppressLint("SetJavaScriptEnabled")
    protected void setupWebView() {
        w.setWebChromeClient(new WebChromeClient());
        w.setWebViewClient(new WebViewClient() {
            @Override
            public void onPageFinished(WebView v, String u) {
                setTitle(v.getTitle());
                super.onPageFinished(v, u);
            }
        });

        WebSettings ws = w.getSettings();
        ws.setJavaScriptEnabled(true);
        ws.setDomStorageEnabled(true);
        ws.setBuiltInZoomControls(true);
        ws.setDisplayZoomControls(false);
        ws.setSupportZoom(true);
        ws.setDefaultTextEncodingName("utf-8");

        w.loadUrl("http://localhost:5123/");
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        System.exit(0);
    }

    @Override
    protected void onPause() {
        super.onPause();
        paused = true;
    }
}
