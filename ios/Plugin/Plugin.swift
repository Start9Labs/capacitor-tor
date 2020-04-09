import Foundation
import Capacitor
import Tor

/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitor.ionicframework.com/docs/plugins/ios
 */
@objc(TorClientPlugin)
public class TorClientPlugin: CAPPlugin {
    var urlSessionConfiguration: URLSessionConfiguration? = nil
    var restClient: Rest? = nil
    
    @objc func initTor(_ call: CAPPluginCall) {
        let onionConnector = OnionConnecter.init()
        onionConnector.start(progress: { (i: Int) in
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
    
    @objc func sendReq(_ call: CAPPluginCall) {
        guard let host = call.getString("host") else {
            call.reject("Must provide a host")
            return
        }
        guard let port = call.getInt("port") else {
            call.reject("Must provide a port")
            return
        }

         // Path should have leading '/'
        guard let path = call.getString("path") else {
            call.reject("Must provide a path")
            return
        }

//        guard let verb = call.getString("verb") else {
//            call.reject("Must provide a verb")
//            return
//        }
//        let data = call.getObject("data")
                
        if restClient != nil {
            restClient!.run(method: .GET, url: "http://" + host + ":" + String(port) + path, data: nil, completion: { result in
                switch result {
                    case .success(let body):
                        call.resolve(body)
                    case .failure(.anyerror(let description)):
                        call.reject(description)
                }
            })
        } else {
            call.reject("No rest client available. Has Tor finished setting up?")
        }
    }
}
