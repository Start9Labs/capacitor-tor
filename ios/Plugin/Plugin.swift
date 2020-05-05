import Foundation
import Capacitor
import Tor

/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitor.ionicframework.com/docs/plugins/ios
 */
@objc(TorPlugin)
public class TorPlugin: CAPPlugin {
    var urlSessionConfiguration: URLSessionConfiguration? = nil
    var restClient: Rest? = nil
    let onionConnector = OnionConnecter.init()
    let onionManager = OnionManager.shared
    
    @objc func start(_ call: CAPPluginCall) {
        let socksPort = call.getInt("socksPort") ?? 9050
        onionConnector.start(manager: onionManager, socksPort: socksPort, progress: { (i: Int) in
            self.notifyListeners("torInitProgress", data: ["progress" : String(i)])
        }, completion: { result in
            switch result {
            case .success(let urlSessionConfiguration):
                self.restClient = Rest.init(urlSessionConfiguration: urlSessionConfiguration)
                call.resolve()
            case .failure(let error):
                call.error(error.localizedDescription)
            }
        })
        
    }
    
    //    stop()   : Promise<void>
    @objc func stop(_ call: CAPPluginCall) {
        onionManager.stopTor()
        call.resolve()
    }

    @objc func reconnect(_ call: CAPPluginCall) {
        onionManager.torReconnect(completion: { established in self.notifyListeners("torReconnectSucceeded", data: ["success": established]) })
        call.resolve()
    }

    @objc func networkChange(_ call: CAPPluginCall) {
        onionManager.networkChange(completion: { established in self.notifyListeners("torReconnectSucceeded", data: ["success": established]) })
        call.resolve()
    }

    //    newnym() : Promise<void>
    @objc func newnym(_ call: CAPPluginCall) {
        onionManager.torNewnym(completion: { established in self.notifyListeners("torReconnectSucceeded", data: ["success": established]) })
        call.resolve()
    }

    //    running(): Promise<{running: boolean}>
    @objc func running(_ call: CAPPluginCall) {
        call.resolve(["running" : onionManager.running()])
    }

}

extension Data {
    var hexDescription: String {
        return reduce("") {$0 + String(format: "%02x", $1)}
    }
}
