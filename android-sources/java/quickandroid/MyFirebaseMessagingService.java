package org.qtproject.example.friendup;

import android.app.NotificationManager;
import java.io.*;
import java.util.Map;
import android.net.Uri;
import java.util.HashMap;
import android.content.Context;
import android.app.PendingIntent;
import android.media.RingtoneManager;
import quickandroid.SystemDispatcher;
import android.support.v4.app.NotificationCompat;
import com.google.firebase.messaging.RemoteMessage;

import android.content.Intent;
import quickandroid.QuickAndroidActivity;

import com.google.firebase.messaging.FirebaseMessagingService;
public class MyFirebaseMessagingService extends FirebaseMessagingService {

    @Override public void onMessageReceived(RemoteMessage remoteMessage) {
        if (remoteMessage.getNotification() != null) {
            String data = remoteMessage.getNotification().getBody();
            String title=remoteMessage.getNotification().getTitle();
            Map<String, String> map = new HashMap<String, String>();

            map.put("title", title);
            map.put("message",data);

            SystemDispatcher.dispatch("Notifier.notify", map);
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
        notificationMng=(NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);

        notificationMng.notify(0, notificationBuilder.build());
    }
}
