package com.ambifi.audio.session.bluetooth;


import android.app.Activity;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothHeadset;
import android.bluetooth.BluetoothProfile;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.media.AudioManager;
import android.util.Log;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.modules.core.DeviceEventManagerModule;

import static android.content.Context.AUDIO_SERVICE;

public class BluetoothManager {

    static final String TAG = "BluetoothManager";

    private ReactApplicationContext reactApplicationContext;
    private AudioManager localAudioManager;
    private BluetoothAdapter bluetoothAdapter;
    private BluetoothHeadset bluetoothHeadset;
    private BluetoothDevice connectedHeadset;
    private BroadcastReceiver broadcastReceiver;
    private BluetoothProfile.ServiceListener bluetoothProfileServiceListener;

    public BluetoothManager(ReactApplicationContext reactApplicationContext) {
        this.reactApplicationContext = reactApplicationContext;
        localAudioManager = (AudioManager) reactApplicationContext.getSystemService(AUDIO_SERVICE);
        bluetoothAdapter = BluetoothAdapter.getDefaultAdapter();
    }

    public void init(Activity currentActivity) {
        //Check if bluetooth enabled
        Activity activity = currentActivity;

		Log.i(TAG,"Init bluetooth broadcast receiver, activity: " + activity);

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

                            WritableMap params = Arguments.createMap();
                            params.putBoolean("headsetConnected", true);
                            params.putString("type", "headsetState");
                            params.putString("message", "Bluetooth headset successfully connected");

                            reactApplicationContext
                                    .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                                    .emit("Bluetooth", params);

                        } else {

                            WritableMap params = Arguments.createMap();
                            params.putBoolean("headsetConnected", false);
                            params.putString("type", "headsetState");
                            params.putString("message", "Bluetooth headset connected, unable to start audio");

                            reactApplicationContext
                                    .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                                    .emit("Bluetooth", params);

                            Log.i(TAG,"Bluetooth headset connected, unable to start audio");
                        }
                        localAudioManager.setBluetoothScoOn(true);
                        localAudioManager.startBluetoothSco();
                    }
                }
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
                Log.i(TAG,"Bluetooth broadcast action: " + action);

                int bluetoothHeadsetState = intent.getIntExtra(BluetoothHeadset.EXTRA_STATE,
                        BluetoothHeadset.STATE_DISCONNECTED);

                Log.i(TAG,"Bluetooth headset state " + bluetoothHeadsetState);

                //Device found
                if (bluetoothHeadsetState == BluetoothHeadset.STATE_CONNECTED) {
                    Log.i(TAG,"Attempting to connect bluetooth headset");
                    bluetoothAdapter.getProfileProxy(context, bluetoothProfileServiceListener, BluetoothProfile.HEADSET);

                    //BluetoothHeadsetUtils.enableHeadsetAudio(localAudioManager);
                }
                if(bluetoothHeadsetState == BluetoothHeadset.STATE_DISCONNECTED){
                    Log.i(TAG,"Disconnecting bluetooth headset");


                    localAudioManager.setMode(AudioManager.MODE_NORMAL);
                    localAudioManager.setBluetoothScoOn(false);
                    localAudioManager.stopBluetoothSco();

                    WritableMap params = Arguments.createMap();
                    params.putString("type", "headsetState");
                    params.putBoolean("headsetConnected", false);

                    reactApplicationContext
                            .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                            .emit("Bluetooth", params);

                    //BluetoothHeadsetUtils.disableHeadsetAudio(localAudioManager);
                }
            }
        };

        //register broadcast receiver on activity
        IntentFilter filter = new IntentFilter();
        filter.addAction(BluetoothHeadset.ACTION_CONNECTION_STATE_CHANGED);
        filter.addAction(BluetoothDevice.ACTION_ACL_CONNECTED);
        filter.addAction(BluetoothDevice.ACTION_ACL_DISCONNECTED);

        activity.registerReceiver(broadcastReceiver, filter);
    }

    public void unregister(Activity activity) {
        if(activity != null && broadcastReceiver != null) {
            activity.unregisterReceiver(broadcastReceiver);
        }
    }
}
