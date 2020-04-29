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
    var onionConnector: OnionManager? = nil
    var urlSessionConfiguration: URLSessionConfiguration? = nil
    var restClient: Rest? = nil
    var fdTable: [Int32: Socket] = [:]
    
    @objc func initTor(_ call: CAPPluginCall) {
        let socksPort = call.getInt("socksPort") ?? 9050
        let onionConnector = OnionConnecter.init()
        onionConnector.start(socksPort: socksPort, progress: { (i: Int) in
            print(i)
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
}

extension Data {
    var hexDescription: String {
        return reduce("") {$0 + String(format: "%02x", $1)}
    }
}
