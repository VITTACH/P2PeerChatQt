package quickandroid;

import org.fourthline.cling.support.model.PortMapping;;
import org.fourthline.cling.android.AndroidUpnpService;
import org.fourthline.cling.support.igd.PortMappingListener;

import java.net.*;;
import java.util.*;
import java.io.IOException;

/**
 * Created by VITTACH on 09.02.2017.
 */
public class UPForward {
    public int port = 4445;
    public int RemPort = 4445;
    public InetAddress IPAddress;
    public InetAddress RemIPAddress;
    private DatagramSocket clientSocket;
    protected DatagramPacket receivePacket;
    protected byte[] receiveDat= new byte[1024];
    private AndroidUpnpService uPNPService=null;
    protected List<byte[]> sendData = new ArrayList<>();

    public String getLocalHostlIp() throws IOException {
        Enumeration<NetworkInterface> interfaces = NetworkInterface.getNetworkInterfaces();

        for (NetworkInterface interface_:Collections.list(interfaces)) {
            if(!interface_.isUp()) continue;
            if(interface_.isLoopback())continue;
            Enumeration<InetAddress> addr=interface_.getInetAddresses();
            for (InetAddress address:Collections.list(addr)) {
                if (!address.isReachable((int)3000)) continue;
                if (address instanceof Inet6Address) continue;
                return address.getHostAddress();
            }
        }
        return null;
    }

    public String recieve() throws IOException {
        clientSocket.receive(receivePacket);
        this.RemPort = receivePacket.getPort();
        RemIPAddress = receivePacket.getAddress();

        String modifiedSentence = new String(receivePacket.getData(),0, receivePacket.getLength());
        System.out.println("From server:"+modifiedSentence);

        return modifiedSentence;
    }

    public void send(byte[] myData) throws IOException {
        DatagramPacket sendPacket = new DatagramPacket(myData, myData.length, IPAddress, port);
        clientSocket.send(sendPacket);
    }

    public void sendUdp(String message) throws IOException {
        int size = 16384;
        sendData.clear();
        for (int pos = 0; pos<message.length(); pos+=size) {
            sendData.add(message.substring(pos, Math.min(message.length(), pos + size)).getBytes());
        }

        for (byte[] myData: sendData) {
            System.out.println("Send to client: " + new String(myData));
            send(myData);
        }
    }

    public void runUPnP(AndroidUpnpService aServ, DatagramSocket clientSocket) throws IOException {
        int uPNP = clientSocket.getLocalPort();
        PortMapping[] arr = new PortMapping[1];
        receivePacket=new DatagramPacket(receiveDat, receiveDat.length);

        PeerFinderService.stackTrace += "local-ip: " + getLocalHostlIp()+"\n";
        arr[0] = new PortMapping(uPNP, getLocalHostlIp(), PortMapping.Protocol.UDP, "HopperNet10");

        PortMappingListener portMaplistn = new PortMappingListener(arr);
        /*
        WifiManager wifiCon = (WifiManager) getSystemService(MainActivity.WIFI_SERVICE);
        PortMapping desiredMapping = new PortMapping(upnp, Formatter.formatIpAddress(wifiCon.getConnectionInfo().getIpAddress()), PortMapping.Protocol.UDP, "HopperNet10");
        UpnpService uPNPService =new UpnpServiceImpl(new AndroidUpnpServiceConfiguration(wifiCon));
        */
        this.uPNPService = aServ;
        uPNPService.getRegistry().addListener(portMaplistn);

        uPNPService.getControlPoint().search();
        this.clientSocket= clientSocket;
        clientSocket.setSoTimeout(1000);

        IPAddress = InetAddress.getByName ("91.122.37.152");
    }

    public void closeAllUpnp() throws InterruptedException {
        if (clientSocket != null) {
            clientSocket.close();
        }
    }
}
