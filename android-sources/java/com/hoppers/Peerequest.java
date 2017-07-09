package com.hoppers;

import java.net.*;
import java.math.BigInteger;
import java.io.OutputStream;
import java.io.FileOutputStream;
import org.json.simple.JSONObject;
import java.nio.channels.SocketChannel;

import java.util.Random;
import java.util.ArrayList;
import java.io.IOException;
import java.io.InputStream;
import org.json.simple.parser.JSONParser;
import java.nio.channels.ServerSocketChannel;

import org.qtproject.qt5.android.QtNative;

import android.app.Activity;
import android.content.Context;

/**
 * Created by VITTACH on 11.04.2017
 */
public class Peerequest {
    static Integer port;
    static boolean flag;
    static FileOutputStream fos;
    static Activity activ =QtNative.activity();
    static String rmsg = new String ("");
    static UpForward pf= new UpForward();
    static BigInteger pbk =new BigInteger("1");
    static BigInteger mod =new BigInteger("1");
    static RsaEncrypt my_RSA =new RsaEncrypt();
    static RsaEncrypt himRSA =new RsaEncrypt();
    static JSONParser parser =new JSONParser();
    static JSONObject jsonObj=new JSONObject();

    static void start() {
        my_RSA.init(512);
        pbk = my_RSA.getPublic();
        mod = my_RSA.getModulu();
        himRSA.setPublic(BigInteger.ONE);
        try {
            fos = activ.openFileOutput("ip2p.txt", Context.MODE_APPEND);
        } catch (Exception e) {}

        try {
            startHoper();
        } catch (Exception exception) {
            try {
                fos.write(exception.toString().getBytes());
            } catch (Exception e) {}
        }
    }

    static void sendPublicModuleKey() {
        jsonObj.clear();
        jsonObj.put(("pubKey"),pbk.toString());
        jsonObj.put(("module"),mod.toString());
        try {
            pf.sendUdp(jsonObj.toJSONString());
        } catch (IOException exception) {
            try {
                fos.write(exception.toString().getBytes());
            } catch (Exception e) {}
            exception.printStackTrace();
        }
    }

    static void RSASending(String data) {
        try {
            if (data.contains("ip")) {
                jsonObj=(JSONObject)parser.parse(data);
                pf.port=Integer.valueOf((String)jsonObj.get("pt"));
                pf.IPAddress = InetAddress.getByName((String)jsonObj.get("ip"));
                System.out.println("port=" + pf.port + ", ip= " + pf.IPAddress);

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
            try {
                fos.write(except.toString().getBytes());
            } catch (Exception e) {}
            //e.printStackTrace();
        }
    }

    static void startHoper() throws Exception {
        flag = true;
        try {
            pf.runUPnP();
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

                            sendPublicModuleKey();

                            pf.IPAddress=oldAddr;
                            pf.port=oldPort;
                            continue;
                        }
                        rmsg=new String(my_RSA.decrypt(new BigInteger(recv)).toByteArray());
                    }
                }
                catch (SocketTimeoutException except) {
                    //e.printStackTrace();
                }
            }
        } catch (IOException except1){
            try {
                fos.write(except1.toString().getBytes());
            } catch (Exception e) {}
            except1.printStackTrace();
        } finally {
            fos.close();
            pf.closeAllUpnp();
        }
    }

    static String RSARecive(){
        String tempResult= "";
        if(!rmsg.equals("")) {
            tempResult = rmsg;
            rmsg = "";
        }
        return tempResult;
    }
}
