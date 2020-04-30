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
    private final OnionProxyManager manager = new AndroidOnionProxyManager(getContext(), "torfiles");

    @PluginMethod()
    public void initTor(PluginCall call) throws IOException, InterruptedException {
        Integer socksPort = call.getInt("socksPort");
        if(socksPort == null){
            socksPort = DEFAULT_SOCKS_PORT;
        }

        manager.startWithRepeat(socksPort, TOTAL_SECONDS_PER_TOR_STARTUP, TOTAL_TRIES_PER_TOR_STARTUP,
            new OnionProxyManagerEventHandler() {
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
        });

        call.success();
    }

    @PluginMethod()
    public void stop(PluginCall call) throws IOException {
        manager.stop();
        call.success();
    }

//    @PluginMethod()
//    public void stop(PluginCall call) throws IOException, InterruptedException {
//        OnionProxyManager manager = new AndroidOnionProxyManager(getContext(), "torfiles");
//        Integer socksPort = call.getInt("socksPort");
//        if(socksPort == null){
//            socksPort = DEFAULT_SOCKS_PORT;
//        }
//
//        manager.startWithRepeat(socksPort, TOTAL_SECONDS_PER_TOR_STARTUP, TOTAL_TRIES_PER_TOR_STARTUP,
//            new OnionProxyManagerEventHandler() {
//                @Override
//                public void message(String severity, String msg){
//                    super.message(severity, msg);
//                    if(msg.contains("Bootstrapped")){
//                        try {
//                            String percentStr = msg.split(" ")[1];
//                            String percent = percentStr.substring(0, percentStr.length() - 1);
//                            JSObject ret = new JSObject();
//                            ret.put("progress", percent);
//                            notifyListeners("torInitProgress", ret);
//                        } catch (Exception ignored) { }
//                    }
//                }
//        });
//
//        call.success();
//    }
}

