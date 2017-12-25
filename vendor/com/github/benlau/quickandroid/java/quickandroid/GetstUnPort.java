package quickandroid;

import java.util.logging.*;
import java.net.InetAddress;
import java.util.Enumeration;
import java.net.NetworkInterface;

public class GetstUnPort implements Runnable {
    private int port = 0;
    static Handler handlers;
    private InetAddress iAddress;
    static String [] addrPort = new String[2];
    protected static int line =0;

    static void start() {
        try {
            handlers.setFormatter(new SimpleFormatter());
            Logger.getLogger("de.javawi.jstun").addHandler(handlers);
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
    }

    static String[] startSTUN() {
        handlers = new Handler() {
            @Override
            public void close() throws SecurityException {
            }
            @Override
            public void flush() { }
            @Override
            public void publish(LogRecord loggerRecords) {
                if (line == 1) {
                    String ADR= ": Address ";
                    String m = loggerRecords.getMessage();
                    String address=m.substring(m.indexOf(ADR)+ADR.length(),m.indexOf(","));
                    addrPort[0] = address;
                    String PORT = "Port ";
                    String port = m.substring(m.indexOf(PORT)+PORT.length(), m.length()-1);
                    addrPort[1] = port;
                }
                line++;
            }
        };
        start();

        return addrPort;
    }

    public GetstUnPort(InetAddress iAddress) {
        this.iAddress = iAddress;
    }

    public void run() {
        try {
            new TrunSearch(iAddress, port, "jstun.javawi.de", (3478)).test();
        } catch (InterruptedException fatal) {
            fatal.printStackTrace();
        }
    }
}
