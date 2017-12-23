package quickandroid;

import android.content.*;
import org.qtproject.qt5.android.QtNative;

import android.os.*;
import android.net.Uri;
import android.view.View;

import org.fourthline.cling.android.AndroidUpnpService;
import org.fourthline.cling.android.AndroidUpnpServiceImpl;

public class QuickAndroidActivity
    extends org.qtproject.qt5.android.bindings.QtActivity {
    private static Context myContext;
    static PesrRequest androidUpnpInstance;

    public static void startUpNpForwards() {
        new AsynchronedRequest().execute();
    }

    @Override
    protected void onResume() {
        SystemDispatcher.onActivityResume();
    }

    public static void sendMsg(String msg) {
        androidUpnpInstance.RSASending(msg);
    }

    public static String getStacTrace() {
        return PesrRequest.stackTrace;
    }

    public static void openingMap(String lat, String lon) {
        Uri gmmIntentUri = Uri.parse("http://maps.google.com/maps?saddr=&daddr=" + lat + "," + lon);

        Intent mapIntent = new Intent(Intent.ACTION_VIEW, gmmIntentUri);
        mapIntent.setPackage("com.google.android.apps.maps");

        if ((mapIntent.resolveActivity(myContext.getPackageManager()) != null)) {
        myContext.startActivity(mapIntent);
        }
    }

    @Override
    protected void onActivityResult(int requestCode,int resultCode,Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        SystemDispatcher.onActivityResult(requestCode,resultCode,data);
    }

    static AndroidUpnpService upnpServices;
    ServiceConnection androidServiceConnect = new ServiceConnection() {
        public void onServiceConnected(ComponentName className, IBinder server) {
            upnpServices = (AndroidUpnpService) server;
        }
        public void onServiceDisconnected(ComponentName getClassName) {
            upnpServices = null;
        }
    };

    static class AsynchronedRequest extends AsyncTask<Void,Void,Void> {
        protected Void doInBackground(Void... params) {
            (androidUpnpInstance=new PesrRequest()).start(upnpServices);
            return null;
        }
    }

    @Override
    protected void onDestroy() {
        //This will stop the UPnP service if nobody else is bound to it
        myContext.unbindService(androidServiceConnect);
    }

    @Override
    public void onCreate(Bundle savedInstancesStates) {
        super.onCreate(savedInstancesStates);
        myContext = this;
        // for starting UPnP Cling library you need add jetty.
        getApplicationContext().bindService(new Intent(this, AndroidUpnpServiceImpl.class), androidServiceConnect, Context.BIND_AUTO_CREATE);
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
