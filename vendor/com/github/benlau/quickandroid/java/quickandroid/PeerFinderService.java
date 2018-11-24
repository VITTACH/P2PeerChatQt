package quickandroid;

import java.io.*;
import java.util.Random;
import java.util.ArrayList;

import android.app.Activity;
import android.content.Context;
import org.json.simple.JSONObject;

import org.fourthline.cling.android.AndroidUpnpService;

import java.nio.channels.SocketChannel;
import org.json.simple.parser.JSONParser;
import org.qtproject.qt5.android.QtNative;
import de.javawi.jstun.header.MessageHeader;
import java.nio.channels.ServerSocketChannel;
import de.javawi.jstun.attribute.ChangeRequest;
import de.javawi.jstun.attribute.MappedAddress;
import de.javawi.jstun.attribute.MessageAttribute;

import java.net.*;
import android.util.Log;
import java.io.OutputStream;
import java.math.BigInteger;

class UtilsForJavaNative {
    public static native void sendEventReceiveMsg(String m);
}

/**
 *Created by VITTACH on 11.04.2017
 */
public class PeerFinderService {
    private String[] addr;
    protected static String stackTrace = "";
    private HttpClientService hr = new HttpClientService();
    private static DatagramSocket datagramSocket;
    private Integer port;
    private boolean flag;
    private boolean handsShakeDone = true;
    private Activity activ=QtNative.activity();
    private String rmsg = new String ("");
    private UPForward pf= new UPForward();
    private BigInteger pbk=new BigInteger("1");
    private BigInteger mod=new BigInteger("1");
    private RsaEncrypt my_RSA=new RsaEncrypt();
    private RsaEncrypt himRSA=new RsaEncrypt();
    private JSONParser parser=new JSONParser();
    public JSONObject jsonObj=new JSONObject();

    private static String siteUrl="http://hoppernet.hol.es";

    private static String TAG = "PeersRequest";

    public String[]getStun() throws Exception {
        MessageHeader sendMsHeader =new MessageHeader(MessageHeader.MessageHeaderType.BindingRequest);
        ChangeRequest changeRequest=new ChangeRequest();
        sendMsHeader.addMessageAttribute(changeRequest);

        byte[] recData=sendMsHeader.getBytes();
        datagramSocket=new DatagramSocket();
        datagramSocket.setReuseAddress((true));
        DatagramPacket p = new DatagramPacket((recData), recData.length, InetAddress.getByName("stun.l.google.com"), (19302));
        datagramSocket.send(p);
        DatagramPacket r = new DatagramPacket(new byte[(32)], (32));
        datagramSocket.receive(r);

        MessageHeader receiveMH = new MessageHeader(MessageHeader.MessageHeaderType.BindingResponse);
        receiveMH.parseAttributes(r.getData());
        MappedAddress ma = (MappedAddress) receiveMH.getMessageAttribute(MessageAttribute.MessageAttributeType.MappedAddress);
        Log.d(TAG, String.format("ip=%s,pt=%s", ma.getAddress(), ma.getPort()));
        String[] a;
        a=new String[]{ma.getAddress().toString(),String.valueOf(ma.getPort())};
        return a;
    }

    public void RSASending(String data) {
        Log.d(TAG,String.format("RSASending: the data = %s", data));
        try {
            if (data.contains("ip") == true) {
                jsonObj=(JSONObject) parser.parse(data);
                pf.port=Integer.valueOf((String) jsonObj.get("pt"));
                pf.IPAddress = InetAddress.getByName((String)jsonObj.get("ip"));

                Log.d(TAG,String.format("RSASending: cal sendPublicModuleKey"));
                sendPublicModuleKey();
                return;
            }
            if (data.contains("close") != !(true)) {
                Log.d(TAG,String.format("RSASending: cal closing"));
                flag = !(true);return;
            }

            if (himRSA.getPublic()!=BigInteger.ONE){
                BigInteger bigInteger = new BigInteger((" " + data).getBytes());
                Log.d(TAG,String.format("RSASending: cal sendUdp"));
                pf.sendUdp(himRSA.encrypt((bigInteger)).toString());
            } else {
                String myMessage = "name="+data+"&port="+addr[1]+"&ip="+addr[0];
                Log.d(TAG,String.format("RSASending: myMessage=%s", myMessage));
                hr.sendRequest(myMessage);
            }
        } catch (Exception exception) {exception.printStackTrace();}
    }

    public void startHoper(AndroidUpnpService upnpServices) throws Exception {
        flag = true;
        try {
            pf.runUPnP(upnpServices,datagramSocket);
            while(flag) {
            try {
                String recv = (String) pf.recieve();
                if (recv.isEmpty()) continue;
                if (recv.contains("pubKey")) {
                jsonObj = (JSONObject) parser.parse(recv);
                himRSA.setModulu(new BigInteger((String)jsonObj.get("module")));
                himRSA.setPublic(new BigInteger((String)jsonObj.get("pubKey")));
                Log.d(TAG,String.format("startHoper: the himRSA = %s", himRSA));

                // TODO this code need function
                InetAddress oldAdr;
                int oldPort = pf.port;
                (oldAdr) = pf.IPAddress;
                this.pf.port = pf.RemPort;
                pf.IPAddress = pf.RemIPAddress;

                if (handsShakeDone) {
                    sendPublicModuleKey();
                    handsShakeDone= false;
                }

                pf.IPAddress= oldAdr;
                pf.port = oldPort;
                } else if (!handsShakeDone) {
                    BigInteger receiveMsg = new BigInteger(recv);
                    rmsg = new String(my_RSA.decrypt(receiveMsg).toByteArray());
                    // magical call c++ listener from java layer!
                    Log.d(TAG,String.format("startHoper: call msg = %s", rmsg));
                    UtilsForJavaNative.sendEventReceiveMsg(rmsg);
                }
            } catch (SocketTimeoutException exception) {}
            }
        } catch (Exception exception){
            stackTrace += "startHoper res = " + adaptExceptionsToLog(exception);
        } finally {
            pf.closeAllUpnp();
        }
    }

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
            addr =this.getStun();
            hr.setupURL(siteUrl);
            startHoper(androidsUpnpServ);
        } catch (Exception exceptioned) {
            stackTrace += adaptExceptionsToLog(exceptioned);
        }
    }

    public void sendPublicModuleKey() {
        jsonObj.clear();
        jsonObj.put(("pubKey"),pbk.toString());
        jsonObj.put(("module"),mod.toString());
        try {
            pf.sendUdp(jsonObj.toJSONString());
        } catch (Exception exceptioned) {
            stackTrace += adaptExceptionsToLog(exceptioned);
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
