package org.qtproject.example.vittachpeer;

import org.qtproject.qt5.android.QtNative;

import android.view.View;
import android.app.Activity;
import android.content.Intent;
import android.content.Context;
import android.app.PendingIntent;

import android.app.Notification;
import android.app.NotificationManager;

import quickandroid.SystemDispatcher;
import quickandroid.QuickAndroidActivity;

import java.util.Map;
import java.util.concurrent.atomic.AtomicInteger;


public class PushService {
    private static AtomicInteger notificationCounter;

    static{notificationCounter=new AtomicInteger(1);}

    static void start() {
        SystemDispatcher.addListener(
        new SystemDispatcher.Listener() {

            Notification.Builder m_builder;
            NotificationManager mnotificationManager;

            private void notificationManagerNotify(Map data) {

                final Map messageData = data;
                final Activity activity = QtNative.activity();

                Runnable runnable = new Runnable () {
                    public void run() {
                        try {
                            if(mnotificationManager == null) {
                                mnotificationManager = (NotificationManager) activity.getSystemService(Context.NOTIFICATION_SERVICE);
                                m_builder = new Notification.Builder(activity);
                                m_builder.setSmallIcon(R.drawable.icon);
                            }

                            String message= (String)messageData.get("message");
                            String stitle = (String)messageData.get("title");

                            m_builder.setContentTitle(stitle);
                            m_builder.setContentText(message);

                            Intent notificationInt = new Intent(activity, QuickAndroidActivity.class);
                            // Intent.FLAG_ACTIVITY_CLEAR_TOP|Intent.FLAG_ACTIVITY_SINGLE_TOP
                            notificationInt.setFlags(67108864 |536870912);
                            PendingIntent intent = PendingIntent.getActivity(activity,0, notificationInt, 0);

                            Notification notification = m_builder.build();
                            notification.setLatestEventInfo(activity,stitle,message, intent);

                            mnotificationManager.notify(notificationCounter.getAndIncrement(), notification);
                        } catch (Exception e) { }

                    };
                };
                activity.runOnUiThread(runnable);
            }

            private void hapticFeedbackPerform(Map data) {

                final Map messageData = data;
                final Activity activity = QtNative.activity();
                Runnable runnable = new Runnable () {
                    public void run() {
                        int flags = (Integer) messageData.get("flags");
                        int feedbackConstant = (Integer) messageData.get("feedbackConstant");

                        View rootForView = activity.getWindow().getDecorView().getRootView();
                        rootForView.performHapticFeedback(feedbackConstant, flags);

                        SystemDispatcher.dispatch("hapticFeedbackPerformFinished");
                    };
                };
                activity.runOnUiThread(runnable);
            }

            public void onDispatched(String name , Map data) {
                if(name.equals("Notifier.notify")) {
                    notificationManagerNotify(data);
                    return;
                }
                else if(name.equals("hapticFeedbackPerform")){
                    hapticFeedbackPerform(data);
                    return;
                }
                return;
            }
        });
    }
}
