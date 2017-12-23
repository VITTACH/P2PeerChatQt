package quickandroid;

import java.net.NetworkInterface;
import java.util.logging.*;
import java.net.InetAddress;
import java.util.Enumeration;

public class GetstUnPort implements Runnable {
    private int port;
    private InetAddress iAddress;

    public GetstUnPort(InetAddress iAddress) {
        this.iAddress = iAddress;
        this.port =0;
    }

    public void run() {
        try {
            new TRUNsearch(iAddress, port, "jstun.javawi.de", 3478).test();
        } catch (Exception exp) {
        }
    }

    static String[] startSTUN() {
        final String[] addressPort=new String[2];
        try {
            final int[] line={0};
            Handler h = new Handler() {
                @Override
                public void publish(LogRecord loggerRecords) {
                    if (line[0] == 1) {
                        String ADR= ": Address ";
                        String message = loggerRecords.getMessage();
                        String address = message.substring(message.indexOf(ADR)+ ADR.length(), message.indexOf(","));
                        addressPort[0] = address;

                        String PORT = "Port ";
                        String port = message.substring(message.indexOf(PORT) + PORT.length(), message.length() - 1);
                        addressPort[1] = port;
                    }
                    line[0]++;
                }

                @Override
                public void flush() {
                }

                @Override
                public void close() throws SecurityException {
                }
            };

            h.setFormatter(new SimpleFormatter());
            Logger.getLogger("de.javawi.jstun").addHandler(h);
            Logger.getLogger("de.javawi.jstun").setLevel(Level.FINE);

            Enumeration<NetworkInterface> ifaces = NetworkInterface.getNetworkInterfaces();
            while (ifaces.hasMoreElements()) {
                NetworkInterface iface = ifaces.nextElement();
                Enumeration<InetAddress> myAddresses = iface.getInetAddresses();
                while (myAddresses.hasMoreElements()) {
                    InetAddress iaddress = myAddresses.nextElement();
                    if (Class.forName("java.net.Inet4Address").isInstance(iaddress)) {
                        if(!(iaddress.isLoopbackAddress()&&iaddress.isLinkLocalAddress())){
                            new Thread(new GetstUnPort(iaddress)).start();
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.out.println(e.getMessage());
        }
        return addressPort;
    }
}
