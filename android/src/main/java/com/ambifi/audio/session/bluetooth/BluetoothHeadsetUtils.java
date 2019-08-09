package com.ambifi.audio.session.bluetooth;


import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothProfile;
import android.media.AudioManager;

import java.lang.reflect.Method;

public class BluetoothHeadsetUtils {

    public static boolean isConnected() {
        BluetoothAdapter adapter = BluetoothAdapter.getDefaultAdapter();
        return (adapter != null) && adapter.getProfileConnectionState(BluetoothProfile.HEADSET) == BluetoothProfile.STATE_CONNECTED;
    }

    public static void enableHeadsetAudio(AudioManager audioManager) {

        audioManager.setMode(AudioManager.MODE_IN_COMMUNICATION);
        audioManager.setBluetoothScoOn(true);
        audioManager.startBluetoothSco();
    }

    public static void disableHeadsetAudio(AudioManager audioManager) {
        audioManager.setMode(AudioManager.MODE_NORMAL);
        audioManager.setBluetoothScoOn(false);
        audioManager.stopBluetoothSco();
    }

}
