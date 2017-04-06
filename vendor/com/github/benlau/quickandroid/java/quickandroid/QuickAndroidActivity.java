package quickandroid;

import android.content.Intent;
import android.content.Context;
import org.qtproject.qt5.android.QtNative;

import android.net.Uri;
import android.os.Bundle;
import android.view.View;

public class QuickAndroidActivity extends
    org.qtproject.qt5.android.bindings.QtActivity {
    private static Context myContext;

    public static void openingMap(String lat, String lon) {
        Uri gmmIntentUri = Uri.parse("http://maps.google.com/maps?saddr=&daddr=" + lat + "," + lon);

        Intent mapIntent = new Intent(Intent.ACTION_VIEW, gmmIntentUri);
        mapIntent.setPackage("com.google.android.apps.maps");

        if( (mapIntent.resolveActivity(myContext.getPackageManager()) != null) ) {
        myContext.startActivity(mapIntent);
        }
    }

    @Override
    public void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        myContext = this;
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data){
        super.onActivityResult(requestCode, resultCode, data);
        SystemDispatcher.onActivityResult(requestCode,resultCode,data);
    }

    @Override
    protected void onResume() {
        super.onResume();
        SystemDispatcher.onActivityResume();
    }

    public static void share(String text, String url) {
        if(QtNative.activity()==null) return;
        Intent intent = new Intent();
        intent.setAction(Intent.ACTION_SEND);
        intent.putExtra(Intent.EXTRA_TEXT, text + "\n" + url);
        intent.setType("text/plain");
        QtNative.activity().startActivity(
            Intent.createChooser(intent,"Choose app to share")
        );
    }
}
