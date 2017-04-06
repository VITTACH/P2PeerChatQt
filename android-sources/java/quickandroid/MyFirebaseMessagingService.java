package org.qtproject.example.vittachpeer;

import java.util.Map;
import java.util.HashMap;
import org.json.JSONArray;
import org.json.JSONObject;

import java.io.*;
import android.app.PendingIntent;
import android.media.RingtoneManager;
import quickandroid.SystemDispatcher;

import android.net.Uri;
import android.os.Environment;
import android.content.Intent;
import android.content.Context;
import   android.app.NotificationManager;

import quickandroid.QuickAndroidActivity;
import   android.support.v4.app.NotificationCompat;
import com.google.firebase.messaging.RemoteMessage;
import com.google.firebase.messaging.FirebaseMessagingService;

public class MyFirebaseMessagingService extends FirebaseMessagingService {

    @Override public void onMessageReceived(RemoteMessage remoteMessage) {
        if (remoteMessage.getNotification() != null) {
            String filename = "/sdcard/m2.txt";
            String data = remoteMessage.getNotification().getBody();
            String title=remoteMessage.getNotification().getTitle();
            File sdCard = Environment.getExternalStorageDirectory();
            Map<String, String> map = new HashMap<String, String>();

            filename=filename.replace("/sdcard",sdCard.getAbsolutePath());
            File tempFile = new File(filename);
            try {
                JSONArray ja = new JSONArray();

                JSONObject jo=new JSONObject();
                jo.put("title", title);
                jo.put("message",data);

                ja.put(jo);

                JSONObject mainObjects;
                mainObjects = new JSONObject();
                mainObjects.put("messages",ja);

                FileOutputStream out=new FileOutputStream(tempFile,false);
                out.write(mainObjects.toString().getBytes());
                out.close();
            } catch (Exception e) {
                e.printStackTrace();
            }

            map.put("title", title);
            map.put("message",data);

            SystemDispatcher.dispatch("Notifier.notify",map);
        }
    }

    private void sendNotification(String messageBody) {
        Intent intent = new Intent(this,QuickAndroidActivity.class);
        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
        PendingIntent pendingIntented;
        pendingIntented=PendingIntent.getActivity(this,0,intent,PendingIntent.FLAG_ONE_SHOT);

        Uri defaultSoundUri=RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION);
        NotificationCompat.Builder notificationBuilder = new NotificationCompat.Builder(this)
                .setSmallIcon(R.drawable.icon).setContentTitle("FireCloudMessaging: Message")
                .setContentText(messageBody).setAutoCancel(true).setSound(defaultSoundUri)
                .setContentIntent(pendingIntented);

        NotificationManager notificationMng;
        notificationMng= (NotificationManager)getSystemService(Context.NOTIFICATION_SERVICE);

        notificationMng.notify(0, notificationBuilder.build());
    }
}
