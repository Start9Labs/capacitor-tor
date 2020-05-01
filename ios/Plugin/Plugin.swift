import Foundation
import Capacitor
import Socket
import Tor

/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitor.ionicframework.com/docs/plugins/ios
 */
@objc(TorPlugin)
public class TorPlugin: CAPPlugin {
    var urlSessionConfiguration: URLSessionConfiguration? = nil
    var restClient: Rest? = nil
    var fdTable: [Int32: Socket] = [:]
    let onionConnector = OnionConnecter.init()
    let onionManager = OnionManager.shared
    
    @objc func start(_ call: CAPPluginCall) {
        let socksPort = call.getInt("socksPort") ?? 9050
        onionConnector.start(manager: onionManager, socksPort: socksPort, progress: { (i: Int) in
            print(i)
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

    //    newnym() : Promise<void>
    @objc func newnym(_ call: CAPPluginCall) {
        onionManager.torReconnect()
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
