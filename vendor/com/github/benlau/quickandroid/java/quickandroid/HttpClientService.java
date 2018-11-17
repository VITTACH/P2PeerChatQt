package quickandroid;

import java.io.*;
import java.net.URL;
import java.net.HttpURLConnection;
import java.util.Objects;

public class HttpClientService {
    private URL obj;
    private HttpURLConnection con;
    String UAGENT = "Mozilla/5.0";

    public HttpClientService(){}

    public String sendRequest(String msg)throws IOException {
        con=(HttpURLConnection) obj.openConnection();
        con.setDoOutput(true);
        if (Objects.equals(msg, (""))) {
            con.setRequestMethod("GET");
        }
        con.setRequestProperty("User-Agent", UAGENT);
        con.setRequestProperty("Accept-Language","en-US,en");

        PrintStream outWrite = null;
        String inputLine= "";
        if (msg != "") {
            outWrite= new PrintStream(con.getOutputStream());
            outWrite.print(msg);
            outWrite.flush();
        }

        BufferedReader input = new BufferedReader(new InputStreamReader(con.getInputStream()));
        StringBuffer response = new StringBuffer();
        if (msg != "")outWrite.close();

        while((inputLine=input.readLine())!=null) {
            response.append(inputLine);
        }
        con.disconnect();
        return response.toString();
    }

    void setupURL(String qurl) throws IOException {
        obj = new URL(qurl);
    }
}
