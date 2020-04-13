package tor.client.plugin;

//import android.os.Build;
//import android.support.annotation.RequiresApi;

import com.getcapacitor.JSObject;
import com.getcapacitor.NativePlugin;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;

import org.json.JSONException;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.InetSocketAddress;
import java.net.Socket;
import java.net.URLConnection;
import java.util.concurrent.TimeoutException;

import sockslib.client.Socks5;
import sockslib.client.SocksProxy;
import sockslib.client.SocksSocket;

@NativePlugin()
public class TorClientPlugin extends Plugin {
    private OnionProxyManager manager;
    private SocksProxy torSocksProxy;
    private static final int TOTAL_SECONDS_PER_TOR_STARTUP = 240;
    private static final int TOTAL_TRIES_PER_TOR_STARTUP = 5;
    private final String fileStorageLocation = "torfiles";

    public enum HTTP_VERB {
        GET, POST, PUT, PATCH, DELETE
    }

    @PluginMethod()
    public void initTor(PluginCall call) throws IOException, InterruptedException, TimeoutException {
        manager = new AndroidOnionProxyManager(getContext(), fileStorageLocation);
        manager.startWithRepeat(TOTAL_SECONDS_PER_TOR_STARTUP, TOTAL_TRIES_PER_TOR_STARTUP);

        // Need in an in code way of configuring the port. Right now this is hardcoded into the torrc file
        torSocksProxy = new Socks5(new InetSocketAddress("localhost",59590), "username", "password");
        JSObject ret = new JSObject();
        ret.put("value", 0);
        call.success(ret);
    }

    @PluginMethod()
    public void connect(PluginCall call) {
    }


    @PluginMethod()
    public void send(PluginCall call) throws IOException, JSONException {
        String path = call.getData().getString("path"); // Path should have leading '/'
        String verb = call.getData().getString("verb");
        String host = call.getData().getString("host");
        JSObject data = call.getData().getJSObject("data");
        int port = call.getData().getInt("port");

        Socket socket = new SocksSocket(torSocksProxy, host, port);
        boolean autoflush = true;
        PrintWriter out = new PrintWriter(socket.getOutputStream(), autoflush);
        BufferedReader in = new BufferedReader(new InputStreamReader(socket.getInputStream()));

        out.println("GET " + path + " HTTP/1.0");
        out.println("Accept: */*");
        out.println("Host: " + host + ":" + port);
        out.println("Connection: Close");
        out.println();

        boolean loop = true;
        StringBuilder sb = new StringBuilder(8096);
        while (loop) {
            if (in.ready()) {
                int i = 0;
                while (i != -1) {
                    i = in.read();
                    sb.append((char) i);
                }
                loop = false;
            }
        }
        System.out.println("Got a response!" + sb.toString());

        socket.close();

        RawHttpParser r = new RawHttpParser();
        r.parseRequest(sb.toString());
        JSObject responseBody = new JSObject(r.getMessageBody().trim());

        call.success(responseBody);
    }

    @PluginMethod
    public void recv(PluginCall call) {
    }
}

// initTor(options: {value: string}): Promise<void> {
//     return TorNative.initTor(options)
//   }

//   sendReq (url: string): Promise<{[key: string]: any}> {
//     return TorNative.sendReq({url})
//   }

//   sendVanillaReq(url: string): Promise<{[key: string]: any}> {
//     return TorNative.sendVanillaReq({url})
//   }


