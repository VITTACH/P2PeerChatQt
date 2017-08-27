package quickandroid;

import java.net.*;
import java.math.BigInteger;
import java.io.OutputStream;
import org.json.simple.JSONObject;
import java.nio.channels.SocketChannel;

import android.app.Activity;
import android.content.Context;
import org.qtproject.qt5.android.QtNative;

import java.util.Random;
import java.util.ArrayList;
import java.io.*;
import org.json.simple.parser.JSONParser;
import java.nio.channels.ServerSocketChannel;

import org.fourthline.cling.android.AndroidUpnpService;


class UtilsToJavaNative {
    public static native void sendEventReceiveMsg(String m);
}

/**
 *Created by VITTACH on 11.04.2017
 */
public class Peerequest {
    static String stackTrace = "";
    Integer port;
    boolean flag;
    boolean handsShakeDone = true;
    Activity activ =QtNative.activity();
    String rmsg = new String ("");
    UpForward pf= new UpForward();
    BigInteger pbk =new BigInteger("1");
    BigInteger mod =new BigInteger("1");
    RsaEncrypt my_RSA =new RsaEncrypt();
    RsaEncrypt himRSA =new RsaEncrypt();
    JSONParser parser =new JSONParser();
    JSONObject jsonObj=new JSONObject();

    private String adaptExceptionsToLog(Exception excepts) {
        StringWriter writer=new StringWriter();
        PrintWriter printToWriter = new PrintWriter(writer);
        excepts.printStackTrace(printToWriter);
        printToWriter.flush();
        return writer.toString();
    }

    public void start(AndroidUpnpService androidsUpnpServ) {
        my_RSA.init(512);
        pbk = my_RSA.getPublic();
        mod = my_RSA.getModulu();
        himRSA.setPublic(BigInteger.ONE);

        try {
            startHoper(androidsUpnpServ);
        } catch (Exception exception) {
            stackTrace += "only start res=" + adaptExceptionsToLog(exception);
        }
    }

    public void sendPublicModuleKey() {
        jsonObj.clear();
        jsonObj.put(("pubKey"),pbk.toString());
        jsonObj.put(("module"),mod.toString());
        try {
            pf.sendUdp(jsonObj.toJSONString());
        } catch (IOException exception) {
            exception.printStackTrace();
        }
    }

    public void RSASending(String data) {
        try {
            if (data.contains("ip")) {
                jsonObj=(JSONObject)parser.parse(data);
                pf.port=Integer.valueOf((String)jsonObj.get("pt"));
                pf.IPAddress=InetAddress.getByName((String)jsonObj.get("ip"));

                // TODO this code need function
                sendPublicModuleKey();
                return;
            }
            if (data.contains("close") !=!(true)) {
                flag = !(true);return;
            }

            System.out.println("Received: "+ data);

            if (himRSA.getPublic()!=BigInteger.ONE)
                pf.sendUdp(
                        himRSA.encrypt(
                                new BigInteger(
                                        (" " + data).getBytes())).toString());
            else pf.sendUdp(data);
        }
        catch (Exception except) {
            //e.printStackTrace();
        }
    }

    public void startHoper(AndroidUpnpService upnpServices) throws Exception {
        flag = true;
        try {
            pf.runUPnP(upnpServices);
            while(flag) {
                try {
                    String recv = (String)pf.recieve();
                    if (!recv.isEmpty()) {
                        if (recv.contains("pubKey")) {
                            jsonObj=(JSONObject)parser.parse(recv);
                            himRSA.setModulu(new BigInteger((String)jsonObj.get("module")));
                            himRSA.setPublic(new BigInteger((String)jsonObj.get("pubKey")));

                            // TODO this code need function
                            InetAddress oldAddr;
                            int oldPort =pf.port;
                            oldAddr=pf.IPAddress;
                            pf.port = pf.RemPort;
                            pf.IPAddress = pf.RemIPAddress;

                            if (handsShakeDone) {
                                sendPublicModuleKey();
                                handsShakeDone= false;
                            }

                            pf.IPAddress=oldAddr;
                            pf.port=oldPort;
                            continue;
                        }
                        rmsg=new String(my_RSA.decrypt(new BigInteger(recv)).toByteArray());
                        // magical call c++ listener from java layer
                        UtilsToJavaNative.sendEventReceiveMsg(rmsg);
                    }
                }
                catch (SocketTimeoutException except) {
                    //e.printStackTrace();
                }
            }
        } catch (Exception exception){
            stackTrace += "startHoper res=" + adaptExceptionsToLog(exception);
        } finally {
            pf.closeAllUpnp();
        }
    }

    public String RSARecive(){
        String tempResult= "";
        if(!rmsg.equals("")) {
            tempResult = rmsg;
            rmsg = "";
        }
        return tempResult;
    }
}