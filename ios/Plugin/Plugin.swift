/*
Modifications Copyright (c) 2020 Start9 Labs, LLC

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
documentation files (the "Software"), to deal in the Software without restriction, including without limitation the
rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit
persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the
Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
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
        let controlPort = call.getInt("controlPort") ?? 9051
        onionConnector.start(manager: onionManager, socksPort: socksPort, controlPort: controlPort, progress: { (i: Int) in
            self.notifyListeners("torInitProgress", data: ["progress" : String(i)])
        }, completion: { result in
            switch result {
            case .success(let urlSessionConfiguration):
                self.restClient = Rest.init(urlSessionConfiguration: urlSessionConfiguration)
                call.resolve([:])
            case .failure(let error):
                call.error(error.localizedDescription)
            }
        })
        
    }
    
    //    stop()   : Promise<void>
    @objc func stop(_ call: CAPPluginCall) {
        onionManager.stopTor(completion: {  call.resolve([:]) })
    }

    @objc func reconnect(_ call: CAPPluginCall) {
        onionManager.torReconnect(completion: { established in
                self.handleEstablished(call, established, "tor reconnect")
            }
        )
    }

    //    newnym() : Promise<void>
    @objc func newnym(_ call: CAPPluginCall) {
        onionManager.torNewnym(completion: { established in
                self.handleEstablished(call, established, "tor newnym")
            }
        )
    }

    //    isRunning(): Promise<{running: boolean}>
    @objc func isRunning(_ call: CAPPluginCall) {
        call.resolve(["running" : onionManager.running()])
    }

    func handleEstablished(_ call: CAPPluginCall, _ established: Bool, _ taskDesc: String) {
        if(established){
            CAPLog.print(taskDesc, "Completed")
            call.resolve([:])
        } else {
            CAPLog.print(taskDesc, "Failed")
            call.reject(taskDesc + " failed")
        }
    }
}

extension Data {
    var hexDescription: String {
        return reduce("") {$0 + String(format: "%02x", $1)}
    }
}
