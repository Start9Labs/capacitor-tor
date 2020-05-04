package tor.plugin;

import com.getcapacitor.JSObject;
import com.getcapacitor.NativePlugin;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;

import java.io.IOException;

@NativePlugin()
public class TorPlugin extends Plugin {
    private static final int TOTAL_SECONDS_PER_TOR_STARTUP = 240;
    private static final int TOTAL_TRIES_PER_TOR_STARTUP = 5;
    private static final int DEFAULT_SOCKS_PORT = 9050;

    private OnionProxyManager manager;

    @PluginMethod()
    public void start(PluginCall call) throws IOException, InterruptedException {
        Integer socksPort = call.getInt("socksPort");
        if(socksPort == null){
            socksPort = DEFAULT_SOCKS_PORT;
        }

        getManager().startWithRepeat(
            socksPort, 
            TOTAL_SECONDS_PER_TOR_STARTUP, 
            TOTAL_TRIES_PER_TOR_STARTUP,
            STARTUP_EVENT_HANDLER
        );

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
    public void networkChange(PluginCall call) throws IOException {
        OnionProxyManager manager = getManager();
        if(manager.isRunning()) {
            System.out.println("Tor: reloading network configuration...");
            if (manager.networkChange()) {
                System.out.println("Tor: network configuration reloaded");
                call.success();
                return;
            } else {
                call.reject("Tor: Could not reload network configuration");
                return;
            }
        }
        call.success();
    }

    @PluginMethod()
    public void reconnect(PluginCall call) throws IOException {
        OnionProxyManager manager = getManager();
        if(manager.isRunning()) {
            System.out.println("Tor: reconnecting...");
            if (manager.reconnect()) {
                System.out.println("Tor: reconnected");
                call.success();
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
                System.out.println("Tor: successfully rebuilt tor circuit");
                call.success();
                return;
            } else {
                call.reject("Tor: Could not rebuild tor circtuit");
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

