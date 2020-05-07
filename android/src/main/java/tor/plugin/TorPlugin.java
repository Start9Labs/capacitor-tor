package tor.plugin;

import android.util.Log;

import com.getcapacitor.JSObject;
import com.getcapacitor.NativePlugin;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;

import org.json.JSONObject;

import java.io.IOException;

@NativePlugin()
public class TorPlugin extends Plugin {
    private static final int TOTAL_SECONDS_PER_TOR_STARTUP = 240;
    private static final int TOTAL_TRIES_PER_TOR_STARTUP = 5;
    private static final int DEFAULT_SOCKS_PORT = 9050;

    private OnionProxyManager manager;

    @PluginMethod()
    public void start(PluginCall call) throws IOException, InterruptedException {
        Log.d("TorPlugin", "Kicking off tor");
        Integer socksPort = call.getInt("socksPort");
        if(socksPort == null){
            socksPort = DEFAULT_SOCKS_PORT;
        }

        boolean startedSuccessfully = getManager().startWithRepeat(
            socksPort, 
            TOTAL_SECONDS_PER_TOR_STARTUP, 
            TOTAL_TRIES_PER_TOR_STARTUP,
            STARTUP_EVENT_HANDLER
        );

        Log.d("TorPlugin", "Finishing off tor. Started successfully: " + startedSuccessfully);
        call.success();
    }

    // Kills running tor daemon
    @PluginMethod()
    public void stop(PluginCall call) throws IOException {
        OnionProxyManager manager = getManager();
        if(manager.isRunning()){
            manager.stop();
        }
        call.success();
    }

    @PluginMethod()
    public void reconnect(PluginCall call) throws IOException {
        OnionProxyManager manager = getManager();
        if(manager.isRunning()) {
            Log.d("TorPlugin","Tor: reconnecting...");
            if (manager.reconnect()) {
                Log.d("TorPlugin","Tor: reconnected");
                call.success();
                JSObject ret = new JSObject();
                ret.put("success", true);
                notifyListeners("torReconnectSucceeded", ret);
                return;
            } else {
                call.reject("Tor: Could not reconnect tor daemon");
                return;
            }
        }
        call.success();
    }

    // Reset tor chain
    @PluginMethod()
    public void newnym(PluginCall call) throws IOException {
        OnionProxyManager manager = getManager();
        if(manager.isRunning()){
            if (manager.newnym()) {
                Log.d("TorPlugin","Tor: successfully rebuilt tor circuit");
                call.success();
                JSObject ret = new JSObject();
                ret.put("success", true);
                notifyListeners("torReconnectSucceeded", ret);
                return;
            } else {
                call.reject("Tor: Could not rebuild tor circuit");
                return;
            }
        }
        call.success();
    }

    @PluginMethod()
    public void running(PluginCall call) throws IOException {
        boolean running = getManager().isRunning();
        JSObject object = new JSObject();
        object.put("running", running);
        call.success(object);
    }

    private OnionProxyManager getManager() {
        if(manager == null){
            manager = new AndroidOnionProxyManager(getContext(), "torfiles");
        }
        return manager;
    }

    private OnionProxyManagerEventHandler STARTUP_EVENT_HANDLER = new OnionProxyManagerEventHandler() {
        @Override
        public void message(String severity, String msg){
            super.message(severity, msg);
            if(msg.contains("Bootstrapped")){
                try {
                    String percentStr = msg.split(" ")[1];
                    String percent = percentStr.substring(0, percentStr.length() - 1);
                    JSObject ret = new JSObject();
                    ret.put("progress", percent);
                    notifyListeners("torInitProgress", ret);
                } catch (Exception ignored) { }
            }
        }
    };

}

