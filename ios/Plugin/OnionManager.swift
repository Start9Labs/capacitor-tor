/*
 * Onion Browser
 * Copyright (c) 2012-2018, Tigas Ventures, LLC (Mike Tigas)
 *
 * This file is part of Onion Browser. See LICENSE file for redistribution terms.
 */
// swiftlint:disable all
import Foundation
import Tor

protocol OnionManagerDelegate {
    func torConnProgress(_: Int)
    func torConnFinished(socksPort: Int, configuration: URLSessionConfiguration)
    func torConnError()
}

public class OnionManager: NSObject {
    public enum TorState: Int {
        case none
        case started
        case connected
        case stopped
    }

    public static let shared = OnionManager()

    private var reachability: Reachability?

    // Show Tor log in iOS' app log.
    private static let TOR_LOGGING = false

    private static let torBaseConf: TorConfiguration = {
        // Store data in <appdir>/Library/Caches/tor (Library/Caches/ is for things that can persist between
        // launches -- which we'd like so we keep descriptors & etc -- but don't need to be backed up because
        // they can be regenerated by the app)
        let dirPaths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        let docsDir = dirPaths[0].path
        let dataDir = URL(fileURLWithPath: docsDir, isDirectory: true).appendingPathComponent("tor", isDirectory: true)
        #if DEBUG
        print("[\(String(describing: OnionManager.self))] dataDir=\(dataDir)")
        #endif

        // Create tor data directory if it does not yet exist
        do {
            try FileManager.default.createDirectory(atPath: dataDir.path, withIntermediateDirectories: true, attributes: nil)
        } catch let error as NSError {
            print("[\(String(describing: OnionManager.self))] error=\(error.localizedDescription))")
        }
        // Create tor v3 auth directory if it does not yet exist
        let authDir = URL(fileURLWithPath: dataDir.path, isDirectory: true).appendingPathComponent("auth", isDirectory: true)
        do {
            try FileManager.default.createDirectory(atPath: authDir.path, withIntermediateDirectories: true, attributes: nil)
        } catch let error as NSError {
            print("[\(String(describing: OnionManager.self))] error=\(error.localizedDescription))")
        }

        // Configure tor and return the configuration object
        let configuration = TorConfiguration()
        configuration.cookieAuthentication = true
        configuration.dataDirectory = dataDir

        #if DEBUG
        let log_loc = "notice stdout"
        #else
        let log_loc = "notice file /dev/null"
        #endif

        var config_args = [
            "--allow-missing-torrc",
            "--ignore-missing-torrc",
            "--controlport", "127.0.0.1:39060",
            "--log", log_loc,
            "--ClientOnionAuthDir", authDir.path
        ]

        configuration.arguments = config_args
        return configuration
    }()

    // MARK: - OnionManager instance
    private var torController: TorController?

    private var torThread: TorThread?

    public var state = TorState.none
    private var initRetry: DispatchWorkItem?
    private var failGuard: DispatchWorkItem?

    private var customBridges: [String]?
    private var needsReconfiguration: Bool = false
    
    @objc func networkChange() {
        var confs: [Dictionary<String, String>] = []
        
        confs.append(["key": "ClientPreferIPv6DirPort", "value": "auto"])
        confs.append(["key": "ClientPreferIPv6ORPort", "value": "auto"])
        confs.append(["key": "clientuseipv4", "value": "1"])
        torController?.setConfs(confs, completion: { _, _ in
        })
        torController?.resetConnection(nil)
    }

    func torReconnect(completion: @escaping (Bool) -> Void) {
        torController?.resetConnection(completion)
    }

    func torNewnym(completion: @escaping (Bool) -> Void) {
        torController?.sendCommand("SIGNAL NEWNYM", arguments: nil, data: nil, observer: { codes, _, stop -> Bool in
            completion(codes.first?.intValue == 250)
            stop.pointee = true
            return true
        })
    }

    func startTor(socksPort: Int, delegate: OnionManagerDelegate?) {
        cancelInitRetry()
        cancelFailGuard()
        state = .started

        if (self.torController == nil) {
            self.torController = TorController(socketHost: "127.0.0.1", port: 39060)
        }

        reachability = try? Reachability()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.networkChange), name: NSNotification.Name.reachabilityChanged, object: nil)
        try? reachability?.startNotifier()

        if ((self.torThread == nil) || (self.torThread?.isCancelled ?? true)) {
            self.torThread = nil

            let torConf = OnionManager.torBaseConf

            let args = torConf.arguments! +  ["--socksport","127.0.0.1:" + String(socksPort)]

            #if DEBUG
            dump("\n\n\(String(describing: args))\n\n")
            #endif
            torConf.arguments = args
            self.torThread = TorThread(configuration: torConf)
            needsReconfiguration = false

            self.torThread!.start()

            print("[\(String(describing: OnionManager.self))] Starting Tor")
        } else {
            if needsReconfiguration {
                // Not using bridges, so null out the "Bridge" conf
                torController!.setConfForKey("usebridges", withValue: "0", completion: { _, _ in
                })
                torController!.resetConf(forKey: "bridge", completion: { _, _ in
                })
            }
        }

        // Wait long enough for tor itself to have started. It's OK to wait for this
        // because Tor is already trying to connect; this is just the part that polls for
        // progress.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            if OnionManager.TOR_LOGGING {
                // Show Tor log in iOS' app log.
                TORInstallTorLogging()
                TORInstallEventLogging()
            }

            if !(self.torController?.isConnected ?? false) {
                do {
                    try self.torController?.connect()
                } catch {
                    print("[\(String(describing: OnionManager.self))] error=\(error)")
                }
            }

            let cookieURL = OnionManager.torBaseConf.dataDirectory!.appendingPathComponent("control_auth_cookie")
            let cookie = try! Data(contentsOf: cookieURL)

            #if DEBUG
            print("[\(String(describing: OnionManager.self))] cookieURL=", cookieURL as Any)
            print("[\(String(describing: OnionManager.self))] cookie=", cookie)
            #endif

            self.torController?.authenticate(with: cookie, completion: { success, _ in
                if success {
                    var completeObs: Any?
                    completeObs = self.torController?.addObserver(forCircuitEstablished: { established in
                        if established {
                            self.state = .connected
                            self.torController?.removeObserver(completeObs)
                            self.cancelInitRetry()
                            self.cancelFailGuard()
                            #if DEBUG
                            print("[\(String(describing: OnionManager.self))] connection established")
                            #endif

                            self.torController?.getSessionConfiguration({ configuration in
                                delegate?.torConnFinished(socksPort: socksPort, configuration: configuration!)
                            })
                        }
                    }) // torController.addObserver
                    var progressObs: Any?
                    progressObs = self.torController?.addObserver(forStatusEvents: {
                        (type: String, _: String, action: String, arguments: [String: String]?) -> Bool in

                        if type == "STATUS_CLIENT" && action == "BOOTSTRAP" {
                            let progress = Int(arguments!["PROGRESS"]!)!
                            #if DEBUG
                            print("[\(String(describing: OnionManager.self))] progress=\(progress)")
                            #endif

                            delegate?.torConnProgress(progress)

                            if progress >= 100 {
                                self.torController?.removeObserver(progressObs)
                            }

                            return true
                        }

                        return false
                    }) // torController.addObserver
                } // if success (authenticate)
                else { print("[\(String(describing: OnionManager.self))] Didn't connect to control port.") }
            }) // controller authenticate
        }) //delay
        initRetry = DispatchWorkItem {
            #if DEBUG
            print("[\(String(describing: OnionManager.self))] Triggering Tor connection retry.")
            #endif
            self.torController?.setConfForKey("DisableNetwork", withValue: "1", completion: { _, _ in
            })

            self.torController?.setConfForKey("DisableNetwork", withValue: "0", completion: { _, _ in
            })

            self.failGuard = DispatchWorkItem {
                if self.state != .connected {
                    delegate?.torConnError()
                }
            }

            // Show error to user, when, after 90 seconds (30 sec + one retry of 60 sec), Tor has still not started.
            DispatchQueue.main.asyncAfter(deadline: .now() + 60, execute: self.failGuard!)
        }

        // On first load: If Tor hasn't finished bootstrap in 30 seconds,
        // HUP tor once in case we have partially bootstrapped but got stuck.
        DispatchQueue.main.asyncAfter(deadline: .now() + 30, execute: initRetry!)

    }// startTor
    /**
     Experimental Tor shutdown.
     */
    @objc func stopTor() {
        print("[\(String(describing: OnionManager.self))] #stopTor")

        // under the hood, TORController will SIGNAL SHUTDOWN and set it's channel to nil, so
        // we actually rely on that to stop tor and reset the state of torController. (we can
        // SIGNAL SHUTDOWN here, but we can't reset the torController "isConnected" state.)
        var confs: [Dictionary<String, String>] = []
        confs.append(["key": "DisableNetwork", "value": "1"])
        self.torController?.setConfs(confs, completion: { _, _ in })
        
        self.torController?.disconnect()
        
        self.torController = nil
        // More cleanup
        self.torThread?.cancel()
        self.torThread = nil
        self.state = .stopped
    }
    
    @objc func running() -> Bool {
        if let ret = self.torThread {
          return ret.isExecuting
        } else {
          return false
        }
    }

    /**
     Cancel the connection retry
     */
    private func cancelInitRetry() {
        initRetry?.cancel()
        initRetry = nil
    }

    /**
     Cancel the fail guard.
     */
    private func cancelFailGuard() {
        failGuard?.cancel()
        failGuard = nil
    }
}
