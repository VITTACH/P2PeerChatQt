package org.qtproject.example.friendup;

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
    private static AtomicInteger notifyMyCounter;

    static{notifyMyCounter=new AtomicInteger(1);}

    static void start() {
        SystemDispatcher.addListener(new SystemDispatcher.Listener(){

            NotificationManager mManager;
            Notification.Builder builder;

            private void notificationManagerNotify(Map data) {

                final Map messageData = data;
                final Activity activity = QtNative.activity();

                Runnable runnable=new Runnable(){
                    public void run() {
                        try {
                            if(mManager == null){
                                mManager = (NotificationManager) activity.getSystemService(Context.NOTIFICATION_SERVICE);
                                builder= new Notification.Builder((activity));
                                builder.setSmallIcon(R.drawable.icon);
                            }

                            String message=(String)messageData.get("message");
                            String stitle = (String) messageData.get("title");

                            builder.setContentTitle(stitle);
                            builder.setContentText(message);

                            Intent notifyIntent = new Intent(activity,QuickAndroidActivity.class);
                            // Intent.FLAG_ACTIVITY_CLEAR_TOP|Intent.FLAG_ACTIVITY_SINGLE_TOP
                            notifyIntent.setFlags(67108864 | 536870912);
                            PendingIntent intent;
                            intent = PendingIntent.getActivity(activity, 0, notifyIntent, 0);

                            Notification notification = builder.build();
                            notification.setLatestEventInfo(activity,stitle,message, intent);

                            mManager.notify(notifyMyCounter.getAndIncrement(), notification);
                        } catch (Exception e) { }

                    };
                };
                activity.runOnUiThread(runnable);
            }

            private void hapticFeedbackPerform(Map data) {

                final Map messageData = data;
                final Activity activity = QtNative.activity();
                Runnable runnable = new Runnable() {
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
                } else {
                    if(name.equals("hapticFeedbackPerform")) {
                        hapticFeedbackPerform(data);
                        return;
                    }
                }
                return;
            }
        });
    }
}
