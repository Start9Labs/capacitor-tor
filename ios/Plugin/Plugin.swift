import Foundation
import Capacitor
import Socket
import Tor

/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitor.ionicframework.com/docs/plugins/ios
 */
@objc(TorClientPlugin)
public class TorClientPlugin: CAPPlugin {
    var onionConnector: OnionManager? = nil
    var urlSessionConfiguration: URLSessionConfiguration? = nil
    var restClient: Rest? = nil
    var fdTable: [Int32: Socket] = [:]
    
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
    
    @objc func connect(_ call: CAPPluginCall) {
        // open socket
        guard let socket = try? Socket.create(family: .inet, type: .stream, proto: .tcp) else {
            call.reject("Could not create socket")
            return
        }
        do {
            try socket.connect(to: "localhost", port: 59590, timeout: 30000)
        } catch {
            call.reject("Could not connect socket")
            return
        }
        
        // save socket to internal map
        self.fdTable[socket.socketfd] = socket
        
        // send socks5 greeting message with supported auth methods
        do {
            let greet: [UInt8] = [0x05, 0x01, 0x00]
            let data = NSData(bytes: greet, length: greet.count)
            print("\(data)")
            try socket.write(from: data)
        } catch {
            call.reject("Could not send Socks5 greeting packet")
            return
        }
        
        // read server choice for auth method
        guard let greetResp = NSMutableData.init(capacity: 2) else {
            call.reject("Could not allocate greet response buffer")
            return
        }
        guard let n = try? socket.read(into: greetResp) else {
            call.reject("Could not read from socket into greet response buffer")
            return
        }
        print("n: \(n)")
        print("greetResp: \(greetResp)")
        
        // send client connection request
        
        // read server response grant, the connection is now ready.
        
        call.resolve(["socketfd": socket.socketfd])
    }
    
    @objc func send(_ call: CAPPluginCall) {
        call.resolve()
    }
    
    @objc func recv(_ call: CAPPluginCall) {
        call.resolve()
    }
    
    @objc func close(_ call: CAPPluginCall) {
        guard let socketfd = call.getInt("socketfd") else {
            call.reject("Must provide 'socketfd: int32'")
            return
        }
        guard let socket = self.fdTable[Int32(socketfd)] else {
            call.reject("Invalid socket descriptor: \(socketfd)")
            return
        }
        socket.close()
        fdTable.removeValue(forKey: Int32(socketfd))
        call.resolve()
    }
    
}

extension Data {
    var hexDescription: String {
        return reduce("") {$0 + String(format: "%02x", $1)}
    }
}
