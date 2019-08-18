package com.ambifi.audio.session;

import android.app.Activity;
import android.util.Log;

import com.facebook.react.bridge.LifecycleEventListener;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;

import java.util.Timer;
import java.util.TimerTask;

public class RNAudioSessionModule extends ReactContextBaseJavaModule implements LifecycleEventListener {

    static final String TAG = "RNAudioSessionModule";

    private AudioRouteManager audioRouteManager;

    public RNAudioSessionModule(ReactApplicationContext reactApplicationContext) {
        super(reactApplicationContext);
        reactApplicationContext.addLifecycleEventListener(this);
        this.audioRouteManager = new AudioRouteManager(reactApplicationContext);
    }

    @ReactMethod
    public void init(Promise promise) {
        Activity activity = this.getCurrentActivity();
        final Promise finalPromise = promise;
        if (activity == null) {
            Log.i(TAG, "Current activity is null, attempt RNAudioSessionModule re-initialize in 50 milliseconds ...");
            Timer timer = new Timer();
            timer.schedule(new TimerTask() {
                @Override
                public void run() {
                    init(finalPromise);
                }
            }, 50);
            return;
        }
        this.audioRouteManager.dispatchCurrentAudioRoute();
    }

    @ReactMethod
    public void resetAudio(Promise promise) {
        audioRouteManager.resetAudio();
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
