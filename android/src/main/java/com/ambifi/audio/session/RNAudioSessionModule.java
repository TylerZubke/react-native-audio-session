package com.ambifi.audio.session;

import android.util.Log;

import com.facebook.react.bridge.LifecycleEventListener;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;

public class RNAudioSessionModule extends ReactContextBaseJavaModule implements LifecycleEventListener {

    static final String TAG = "RNAudioSessionModule";

    private AudioRouteManager audioRouteManager;

    public RNAudioSessionModule(ReactApplicationContext reactApplicationContext) {
        super(reactApplicationContext);
        reactApplicationContext.addLifecycleEventListener(this);
        this.audioRouteManager = new AudioRouteManager(reactApplicationContext);


    }

    @Override
    public void onHostResume() {
        Log.i(TAG, "Host resume");
        audioRouteManager.init(this.getCurrentActivity());
    }

    @Override
    public void onHostPause() {
        Log.i(TAG, "Host pause");
        audioRouteManager.unregister(this.getCurrentActivity());
    }

    @Override
    public void onHostDestroy() {

    }

    @Override
    public String getName() {
        return "RNAudioSession";
    }
}
