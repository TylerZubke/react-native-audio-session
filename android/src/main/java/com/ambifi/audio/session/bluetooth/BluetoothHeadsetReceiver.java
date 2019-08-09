package com.ambifi.audio.session.bluetooth;

import android.bluetooth.BluetoothHeadset;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.media.AudioManager;
import android.util.Log;

public class BluetoothHeadsetReceiver extends BroadcastReceiver {
    private AudioManager localAudioManager;

    private final String TAG = "headsetAudioState";
    @Override
    public void onReceive(Context context, Intent intent) {

        localAudioManager = (AudioManager) context.getSystemService(Context.AUDIO_SERVICE);
        String action = intent.getAction();
        Log.i(TAG,"in broadcast");

        if (BluetoothHeadset.ACTION_CONNECTION_STATE_CHANGED.equals(action)) {
            int bluetoothHeadsetState = intent.getIntExtra(BluetoothHeadset.EXTRA_STATE,
                    BluetoothHeadset.STATE_DISCONNECTED);
            Log.i(TAG,bluetoothHeadsetState+" ");

            //Device found
            if (bluetoothHeadsetState == BluetoothHeadset.STATE_CONNECTED) {

                Log.i(TAG,bluetoothHeadsetState+" connected");

                BluetoothHeadsetUtils.enableHeadsetAudio(localAudioManager);

            }
            if(bluetoothHeadsetState == BluetoothHeadset.STATE_DISCONNECTED){

                Log.i(TAG,bluetoothHeadsetState+" disconnected");

                BluetoothHeadsetUtils.disableHeadsetAudio(localAudioManager);
            }
        }
    }
}
