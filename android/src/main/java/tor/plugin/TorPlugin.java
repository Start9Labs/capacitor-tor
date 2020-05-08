package tor.plugin;

import android.util.Log;

import com.getcapacitor.JSObject;
import com.getcapacitor.NativePlugin;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;

import java.io.IOException;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

@NativePlugin()
public class TorPlugin extends Plugin {
    private static final int TOTAL_SECONDS_PER_TOR_STARTUP = 240;
    private static final int TOTAL_TRIES_PER_TOR_STARTUP = 5;
    private static final int DEFAULT_SOCKS_PORT = 9050;
    private final ExecutorService executorService = Executors.newCachedThreadPool();
    private OnionProxyManager manager;

    @PluginMethod()
    public void start(PluginCall call) {
        executorService.execute(() -> {
            Log.d("TorPlugin", "Kicking off tor");
            Integer socksPort = call.getInt("socksPort");
            if(socksPort == null){
                socksPort = DEFAULT_SOCKS_PORT;
            }

            boolean startedSuccessfully;
            try {
                startedSuccessfully = getManager().startWithRepeat(
                        socksPort,
                        TOTAL_SECONDS_PER_TOR_STARTUP,
                        TOTAL_TRIES_PER_TOR_STARTUP,
                        STARTUP_EVENT_HANDLER
                );
                Log.d("TorPlugin", "Finishing off tor. Started successfully: " + startedSuccessfully);
                call.success();
            } catch (Exception e) {
                call.reject(e.getLocalizedMessage(), e);
            }
        });
    }

    // Kills running tor daemon
    @PluginMethod()
    public void stop(PluginCall call) {
        executorService.execute(() -> {
            OnionProxyManager manager = getManager();
            if(isRunning(call)){
                try {
                    manager.stop();
                } catch (IOException e) {
                    call.reject(e.getLocalizedMessage(), e);
                }
            }
            call.success();
        });

    }

    @PluginMethod()
    public void reconnect(PluginCall call) {
        executorService.execute(() -> {
            if(!isRunning(call)) {
                call.success();
            }

            Log.d("TorPlugin","Tor: reconnecting...");
            if (getManager().reconnect()) {
                Log.d("TorPlugin","Tor: reconnected");
                call.success();
            } else {
                call.reject("Tor: Could not reconnect tor daemon");
            }
        });
    }

    @PluginMethod()
    public void newnym(PluginCall call) {
        executorService.execute(() -> {
            if(!isRunning(call)) {
                call.success();
            }

            if (getManager().newnym()) {
                Log.d("TorPlugin","Tor: successfully rebuilt tor circuit");
                call.success();
            } else {
                call.reject("Tor: Could not rebuild tor circuit");
            }
        });
    }

    private boolean isRunning(PluginCall call) {
        try {
            return getManager().isRunning();
        } catch (IOException e) {
            call.reject(e.getLocalizedMessage(), e);
            return false;
        }
    }

    @PluginMethod()
    public void running(PluginCall call) {
        boolean running = isRunning(call);
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

