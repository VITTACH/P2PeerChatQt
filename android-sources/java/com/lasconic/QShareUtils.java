package com.lasconic;

import java.lang.String;
import android.util.Log;
import android.content.Intent;

import org.qtproject.qt5.android.QtNative;

public class QShareUtils {
    protected QShareUtils() {
       Log.d("lasconic","QShareUtils()");
    }

    public static void share(String text, String url) {
        if(QtNative.activity() == null) {
            Log.d("lasconic", "Fail");
            return;
        }

        Log.d("lasconic","Try to share");
        Intent sendIntent = new Intent();
        sendIntent.setType("text/plain");
        sendIntent.setAction(Intent.ACTION_SEND);
        sendIntent.putExtra
        (Intent.EXTRA_TEXT, text + "\n\n" + url);

        QtNative.activity().startActivity
        (Intent.createChooser(sendIntent, "Поделись"));
    }
}
