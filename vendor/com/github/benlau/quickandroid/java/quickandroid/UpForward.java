package quickandroid;

import java.net.*;
import java.util.Random;
import java.io.IOException;
import java.util.Collections;
import java.util.Enumeration;

import org.fourthline.cling.UpnpServiceImpl;
import org.fourthline.cling.support.model.PortMapping;
import org.fourthline.cling.support.igd.PortMappingListener;

/**
 * Created by VITTACH on 09.02.2017.
 */
public class UpForward {
    public int port = 4445;
    public int RemPort = 4445;
    public InetAddress IPAddress;
    public InetAddress RemIPAddress;
    public DatagramSocket clientSoket;
    public DatagramPacket receivePacket;
    public byte[] sendData = new byte[1024];
    public byte[] receiveDat = new byte[1024];
    public UpnpServiceImpl upnpService = null;

    public String getLocalHostlIp() throws IOException {
        Enumeration<NetworkInterface> interfaces = NetworkInterface.getNetworkInterfaces();

        for (NetworkInterface interface_:Collections.list(interfaces)) {
            if(!interface_.isUp()) continue;
            if(interface_.isLoopback())continue;
            Enumeration<InetAddress> addr=interface_.getInetAddresses();
            for (InetAddress address:Collections.list(addr)) {
                if (!address.isReachable(3000)) continue;
                if (address instanceof Inet6Address) continue;
                /*
                try(SocketChannel socket=SocketChannel.open()) {
                    socket.socket().setSoTimeout(3000);
                    socket.bind(new InetSocketAddress(address, 8080));
                    socket.connect(new InetSocketAddress("fb.com", 80));
                }catch (IOException ex) {
                    ex.printStackTrace();
                    continue;
                }

                System.out.format("ni: %s,ia: %s\n",interface_,address);
                */

                return address.getHostAddress();
            }
        }
        return null;
    }

    public String recieve() throws IOException {
        clientSoket.receive(receivePacket);
        RemPort=(int)clientSoket.getPort();
        this.RemIPAddress = (InetAddress) clientSoket.getInetAddress();

        String modifiedSentence = new String(receivePacket.getData(),0, receivePacket.getLength());
        System.out.println("From server:"+modifiedSentence);

        return modifiedSentence;
    }

    public void sendUdp(String message) throws IOException {
        sendData= message.getBytes();
        DatagramPacket sendPacket = new DatagramPacket(sendData, sendData.length, IPAddress, port);
        clientSoket.send(sendPacket);
    }

    public void runUPnP() throws IOException {
        Random r = new Random();
        int upnp = r.nextInt(49151-25087)+25087;
        PortMapping[] arr = new PortMapping[1];
        receivePacket=new DatagramPacket(receiveDat, receiveDat.length);

        arr[0] = new PortMapping(upnp, getLocalHostlIp(), PortMapping.Protocol.UDP, "HopperNet10");

        upnpService = new UpnpServiceImpl(new PortMappingListener(arr));

        upnpService.getControlPoint().search();

        clientSoket = new DatagramSocket(upnp);
        clientSoket.setSoTimeout(1000);

        IPAddress = InetAddress.getByName ("91.122.37.152");

    }

    public void closeAllUpnp() throws InterruptedException {
        clientSoket.close();
        System.out.println("Waiting 10 seconds before shutting down..");
        Thread.sleep(10000);
        // Release resources and advertise BYEBYE to other UPnP devices.
        upnpService.shutdown();
    }
}
