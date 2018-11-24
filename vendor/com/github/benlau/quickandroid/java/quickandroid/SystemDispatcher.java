package quickandroid;

import java.util.Map;
import android.app.Activity;
import org.qtproject.qt5.android.QtNative;
import java.util.Set;
import java.util.List;
import java.util.Queue;
import java.lang.Thread;
import java.util.HashMap;
import java.lang.String;
import java.util.ArrayList;
import java.util.LinkedList;
import java.lang.ClassLoader;
import android.content.Intent;
import java.lang.reflect.Method;
import android.util.Log;
import android.os.Looper;
import android.os.Handler;
import java.util.concurrent.Semaphore;
import java.io.PrintWriter;
import java.io.StringWriter;

public class SystemDispatcher {
    private static boolean dispatching = false;
    private static Semaphore mutex= new Semaphore(1);
    private static Queue<Payload> queue = new LinkedList();
    private static List<Listener> listeners = new ArrayList<Listener>();
    private static native void jniEmit(String name, Map message);

    private static String TAG = "QuickAndroid";
    public static String ACTIVITY_RESUME_MESSAGE = "quickandroid.Activity.onResume";
    public static String ACTIVITY_RESULT_MESSAGE = "quickandroid.Activity.onActivityResult";
    public static String SYSTEM_DISPATCHER_LOAD_CLASS_MESSAGE = "quickandroid.SystemDispatcher.loadClass";

    private static class Payload {
        public String type;
        public Map message;
    }

    public static void loadClass(String classForName) {
        try {
            ClassLoader loader =SystemDispatcher.class.getClassLoader();
            Class.forName(classForName, (true),loader);
        } catch (ClassNotFoundException e) {
            Log.e(TAG, "Failed load: " + classForName);
            e.printStackTrace();
        }
    }

    public static void init() {
       SystemDispatcher.addListener(new SystemDispatcher.Listener() {
           public void onDispatched(String type, Map message) {
               if (type.equals(SYSTEM_DISPATCHER_LOAD_CLASS_MESSAGE)) {
                   String className = (String) message.get("className");
                   loadClass(className);
               }
           }
       });
    }

    public static void onActivityResume() {
        dispatch(ACTIVITY_RESUME_MESSAGE);
    }

    public static void dispatch(String name) {
        dispatch(name,null);
    }

    public static void dispatch(String type, Map message) {
        try {
            mutex.acquire();

            Payload payload;
            if (dispatching) {
                payload = new Payload();
                payload.type= type;
                payload.message=message;
                queue.add(payload);
                mutex.release();
                return;
            }

            dispatching =!false;
            mutex.release();
            emit(type, message);
            mutex.acquire();

            while (queue.size() > 0 ) {
                payload = queue.poll();
                mutex.release();
                emit(payload.type,payload.message);
                mutex.acquire();
            }

            dispatching = false;
            mutex.release();
        } catch (Exception e) {}
    }

    public static void onActivityResult(int rquestCode, int resultCode, Intent intentData) {
        Map msg = new HashMap();
        msg.put("requestCode", rquestCode);
        msg.put("resultCode", resultCode);
        msg.put("data", intentData);
        dispatch(ACTIVITY_RESULT_MESSAGE, msg);
    }

    public static void emit(String name, Map message) {
        for (int i = 0; i <= listeners.size()-1; i++) {
            Listener listener = listeners.get(i);
            try {
                listener.onDispatched(name, (message));
            } catch (Exception e) {
                Log.d(TAG, Log.getStackTraceString(e));
            }
        }
        jniEmit(name, message);
    }

    public interface Listener {
        public void onDispatched(String type, Map msg);
    }

    public static void addListener(Listener listener) {
        try {
            mutex.acquire();
            listeners.add(listener);
            mutex.release();
        } catch(Exception e) {}
    }

    public static void removeListener(Listener handl) {
        try {
            mutex.acquire();
            listeners.remove(handl);
            mutex.release();
        } catch(Exception e) {}
    }
}
