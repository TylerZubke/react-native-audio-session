package com.ambifi.audio.session;

import android.app.Activity;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothHeadset;
import android.bluetooth.BluetoothProfile;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.media.AudioDeviceInfo;
import android.media.AudioManager;
import android.os.Build;
import android.util.Log;

import com.ambifi.audio.session.bluetooth.BluetoothHeadsetUtils;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.modules.core.DeviceEventManagerModule;

import static android.content.Context.AUDIO_SERVICE;

public class AudioRouteManager {

    static final String TAG = "AudioRouteManager";

    private ReactApplicationContext reactApplicationContext;
    private AudioManager localAudioManager;
    private BluetoothAdapter bluetoothAdapter;
    private BluetoothHeadset bluetoothHeadset;
    private BluetoothDevice connectedHeadset;
    private BroadcastReceiver broadcastReceiver;
    private BluetoothProfile.ServiceListener bluetoothProfileServiceListener;
    private boolean hasHeadsetMicrophone = false;

    public AudioRouteManager(ReactApplicationContext reactApplicationContext) {
        this.reactApplicationContext = reactApplicationContext;
        localAudioManager = (AudioManager) reactApplicationContext.getSystemService(AUDIO_SERVICE);
        bluetoothAdapter = BluetoothAdapter.getDefaultAdapter();
    }

    public void init(Activity currentActivity) {
        //Check if bluetooth enabled
        Activity activity = currentActivity;

        AudioRouteManager self = this;

        Log.i(TAG,"Init audio broadcast receiver, activity: " + activity);

        bluetoothProfileServiceListener = new BluetoothProfile.ServiceListener() {
            @Override
            public void onServiceConnected(int profile, BluetoothProfile proxy) {

                if (profile == BluetoothProfile.HEADSET)
                {
                    bluetoothHeadset = (BluetoothHeadset) proxy;
                    if(bluetoothHeadset.getConnectedDevices().size()>0) {

                        connectedHeadset = bluetoothHeadset.getConnectedDevices().get(0);

                        bluetoothHeadset.stopVoiceRecognition(connectedHeadset);

                        try {
                            Thread.sleep(500);
                        } catch(Exception e) {}

                        if(bluetoothHeadset.startVoiceRecognition(connectedHeadset)) {
                            Log.i(TAG,"Bluetooth headset connected and audio started");
                        } else {
                            Log.i(TAG,"Bluetooth headset connected, unable to start audio");
                        }
                    }
                }

                dispatchCurrentAudioRoute();
                localAudioManager.setBluetoothScoOn(true);
                localAudioManager.startBluetoothSco();
            }

            @Override
            public void onServiceDisconnected(int profile) {
            }
        };

        //do initial headphone check
        if(bluetoothAdapter != null) {
            bluetoothAdapter.getProfileProxy(this.reactApplicationContext, bluetoothProfileServiceListener, BluetoothProfile.HEADSET);
        }

        //initialize broadcast receiver
        broadcastReceiver = new BroadcastReceiver() {

            @Override
            public void onReceive(Context context, Intent intent) {

                String action = intent.getAction();
                Log.i(TAG,"Audio broadcast action: " + action);

                if(action.equals(BluetoothHeadset.ACTION_CONNECTION_STATE_CHANGED) ||
                        action.equals(BluetoothDevice.ACTION_ACL_DISCONNECTED) ||
                        action.equals(BluetoothDevice.ACTION_ACL_CONNECTED)) {

                    int bluetoothHeadsetState = intent.getIntExtra(BluetoothHeadset.EXTRA_STATE,
                            BluetoothHeadset.STATE_DISCONNECTED);

                    Log.i(TAG,"Bluetooth headset state " + bluetoothHeadsetState);

                    //Device found
                    if (bluetoothHeadsetState == BluetoothHeadset.STATE_CONNECTED) {
                        Log.i(TAG,"Attempting to connect bluetooth headset");
                        bluetoothAdapter.getProfileProxy(context, bluetoothProfileServiceListener, BluetoothProfile.HEADSET);
                    } else if(bluetoothHeadsetState == BluetoothHeadset.STATE_DISCONNECTED){
                        Log.i(TAG,"Disconnecting bluetooth headset");

                        localAudioManager.setMode(AudioManager.MODE_NORMAL);
                        localAudioManager.setBluetoothScoOn(false);
                        localAudioManager.stopBluetoothSco();

                        dispatchCurrentAudioRoute();
                    }
                } else if (action.equals(Intent.ACTION_HEADSET_PLUG)) {


                    //0 for unplugged, 1 for plugged.
                    int state = intent.getIntExtra("state", -1);

                    // - 1 if headset has a microphone, 0 otherwise, 1 mean h2w
                    int microphone = intent.getIntExtra("microphone", -1);

                    switch (state)
                    {
                        case 0:
                            //headset disconnected
                            hasHeadsetMicrophone = false;
                            break;
                        case 1:
                            //headset connected
                            if(microphone == 1) {
                                hasHeadsetMicrophone = true;
                            } else {
                                hasHeadsetMicrophone = false;
                            }
                            break;
                        default:
                            hasHeadsetMicrophone = false;
                            break;
                    }

                    dispatchCurrentAudioRoute();

                }
            }
        };

        //register broadcast receiver on activity
        IntentFilter filter = new IntentFilter();
        filter.addAction(BluetoothHeadset.ACTION_CONNECTION_STATE_CHANGED);
        filter.addAction(BluetoothDevice.ACTION_ACL_CONNECTED);
        filter.addAction(BluetoothDevice.ACTION_ACL_DISCONNECTED);
        filter.addAction(Intent.ACTION_HEADSET_PLUG);

        activity.registerReceiver(broadcastReceiver, filter);
    }

    public void unregister(Activity activity) {
        if(activity != null && broadcastReceiver != null) {
            activity.unregisterReceiver(broadcastReceiver);
        }
    }

    public boolean isWiredHeadsetOn() {
        boolean isWiredHeadsetOn = false;

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            AudioDeviceInfo[] mAudioDeviceInfos = localAudioManager.getDevices(AudioManager.GET_DEVICES_OUTPUTS);

            for (int i = 0; i < mAudioDeviceInfos.length; i++) {
                if (mAudioDeviceInfos[i].getType() == AudioDeviceInfo.TYPE_WIRED_HEADSET) {
                    isWiredHeadsetOn = true;
                }
            }
        } else {
            isWiredHeadsetOn = localAudioManager.isWiredHeadsetOn();
        }

        return isWiredHeadsetOn;
    }

    public boolean isWiredHeadphonesOn() {
        boolean isWiredHeadphonesOn = false;

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            AudioDeviceInfo[] mAudioDeviceInfos = localAudioManager.getDevices(AudioManager.GET_DEVICES_OUTPUTS);

            for (int i = 0; i < mAudioDeviceInfos.length; i++) {
                if (mAudioDeviceInfos[i].getType() == AudioDeviceInfo.TYPE_WIRED_HEADPHONES) {
                    isWiredHeadphonesOn = true;
                }
            }
        } else {
            isWiredHeadphonesOn = localAudioManager.isWiredHeadsetOn();
        }

        return isWiredHeadphonesOn;
    }

    public void dispatchCurrentAudioRoute() {

        //bluetooth takes priority over headset
        if (BluetoothHeadsetUtils.isConnected()) {
            WritableMap params = Arguments.createMap();
            params.putString("input", "BluetoothHFP");
            params.putString("output", "BluetoothHFP");

            reactApplicationContext
                    .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                    .emit("AudioSessionRouteChanged", params);
        } else if (isWiredHeadsetOn() || isWiredHeadphonesOn()) {

            WritableMap params = Arguments.createMap();

            String input = "Headphones";
            if (hasHeadsetMicrophone == false) {
                input = "MicrophoneBuiltIn";
            }

            params.putString("input", input);
            params.putString("output", "Headphones");

            reactApplicationContext
                    .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                    .emit("AudioSessionRouteChanged", params);
        } else {

            String output = "";
            if(localAudioManager.isSpeakerphoneOn()) {
                output = "Speaker";
            } else {
                output = Build.MODEL;
            }
            WritableMap params = Arguments.createMap();
            params.putString("input", "MicrophoneBuiltIn");
            params.putString("output", output);

            reactApplicationContext
                    .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                    .emit("AudioSessionRouteChanged", params);
        }
    }

    public void resetAudio() {
        localAudioManager.setBluetoothScoOn(false);
        localAudioManager.stopBluetoothSco();
        localAudioManager.setSpeakerphoneOn(false);
        localAudioManager.setMicrophoneMute(false);
        localAudioManager.setMode(AudioManager.MODE_NORMAL);
    }
}
