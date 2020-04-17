package tor.client.plugin;

//import android.os.Build;
//import android.support.annotation.RequiresApi;

import android.net.Proxy;

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

        call.success();
    }
}

