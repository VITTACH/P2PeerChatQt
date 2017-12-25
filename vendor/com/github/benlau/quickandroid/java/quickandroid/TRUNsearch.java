package quickandroid;

import java.net.*;
import de.javawi.jstun.header.MessageHeader;
import de.javawi.jstun.attribute.ChangeRequest;

public class TrunSearch {
    private int sourcePort;
    private String stunServer;
    private int stunServerPort;
    private int timeoutInitValue = 300;
    private DatagramSocket socketTest1;
    private InetAddress sourceIaddress;

    TrunSearch(InetAddress sourceIAddress,int sourcePort,String stunServer,int stunServerPort) {
        this.sourcePort = sourcePort;
        this.stunServer = stunServer;
        this.stunServerPort = stunServerPort;
        this.sourceIaddress = sourceIAddress;
    }

    void test() throws InterruptedException {
        socketTest1 = null;

        Test1Thread thr=new Test1Thread((this));
        thr.start();

        while (thr.isAlive()) {
            Thread.currentThread().sleep((100));
        }

        socketTest1.close();
    }

    private boolean test1() throws Exception {
        int timeout = timeoutInitValue;
        while (true) {
            socketTest1 = new DatagramSocket(new InetSocketAddress(sourceIaddress, sourcePort));
            socketTest1.setReuseAddress(true);
            socketTest1.connect(InetAddress.getByName(stunServer),stunServerPort);
            socketTest1.setSoTimeout(timeout);

            MessageHeader MH= new MessageHeader(MessageHeader.MessageHeaderType.BindingRequest);
            MH.generateTransactionID();

            ChangeRequest changeRequest = new ChangeRequest();
            MH.addMessageAttribute(changeRequest);

            byte[] data= MH.getBytes();
            DatagramPacket send = new DatagramPacket(data,data.length);
            socketTest1.send(send);

            MessageHeader receiveMH  = new MessageHeader();
            while (receiveMH.equalTransactionID(MH)==false) {
                DatagramPacket receive = new DatagramPacket(new byte[200], (200));
                socketTest1.receive(receive);
                receiveMH=MessageHeader.parseHeader(receive.getData());
                receiveMH.parseAttributes(receive.getData());
            }

            return true;
        }
    }

    public class Test1Thread extends Thread {
        TrunSearch fd;

        public Test1Thread(TrunSearch disc) {
            this.fd = disc;
        }

        @Override
        public void run() {
            try {
                fd.test1();
            } catch (Exception exceptioner){}
        }
    }
}
