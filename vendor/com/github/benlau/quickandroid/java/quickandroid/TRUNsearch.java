package quickandroid;

import de.javawi.jstun.util.UtilityException;
import java.net.InetAddress;
import java.net.DatagramSocket;
import java.net.InetSocketAddress;
import java.net.DatagramPacket;
import java.net.SocketTimeoutException;

import de.javawi.jstun.attribute.ChangeRequest;
import de.javawi.jstun.attribute.MessageAttributeException;
import de.javawi.jstun.header.MessageHeader;
import de.javawi.jstun.header.MessageHeaderParsingException;
import de.javawi.jstun.attribute.MessageAttributeParsingException;

import java.io.IOException;

public class TRUNsearch {
    private int sourcePort;
    private String stunServer;
    private int stunServerPort;
    private int timeoutInitValue = 300;
    private DatagramSocket socketTest1;
    private InetAddress sourceIaddress;

    TRUNsearch(InetAddress sourcesIAddress, int sourcePort, String stunServer, int stunsServerPort) {
            this.sourcePort = sourcePort;
            this.stunServer = stunServer;
            this.stunServerPort = stunsServerPort;
            this.sourceIaddress = sourcesIAddress;
    }

    void test() throws UtilityException, IOException, MessageAttributeException, MessageHeaderParsingException {
        socketTest1 = null;

        Test1Thread t1thr = new Test1Thread(this);
        t1thr.start();

        while (t1thr.isAlive()) {
            try {
                Thread.currentThread().sleep(100);
            } catch (InterruptedException excep) {
                excep.printStackTrace();
            }
        }

        socketTest1.close();
    }

    private boolean test1() throws UtilityException, IOException, MessageAttributeParsingException, MessageHeaderParsingException {
        int timeout = timeoutInitValue;
        while (true) {
            try {
                socketTest1 = new DatagramSocket(new InetSocketAddress(sourceIaddress, sourcePort));
                socketTest1.setReuseAddress(true);
                socketTest1.connect(InetAddress.getByName(stunServer),stunServerPort);
                socketTest1.setSoTimeout(timeout);

                MessageHeader sendMH = new MessageHeader(MessageHeader.MessageHeaderType.BindingRequest);
                sendMH.generateTransactionID();

                ChangeRequest changeRequest = new ChangeRequest();
                sendMH.addMessageAttribute(changeRequest);

                byte[] data = sendMH.getBytes();
                DatagramPacket send = new DatagramPacket(data,data.length);
                socketTest1.send(send);

                MessageHeader receiveMH  = new MessageHeader();
                while (!(receiveMH.equalTransactionID(sendMH))) {
                    DatagramPacket receive = new DatagramPacket(new byte[200], (200));
                    socketTest1.receive(receive);
                    receiveMH=MessageHeader.parseHeader(receive.getData());
                    receiveMH.parseAttributes(receive.getData());
                }

                return true;
            }
            catch(SocketTimeoutException e) {
            }
        }
    }

    public class Test1Thread extends Thread {
        TRUNsearch fd;

        public Test1Thread(TRUNsearch disc) {
            this.fd = disc;
        }

        @Override
        public void run() {
            try {
              fd.test1();
            } catch (Exception e) {}
        }
    }
}
