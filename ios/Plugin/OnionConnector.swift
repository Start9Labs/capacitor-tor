//
//  SwiftLnd
//
//  Created by 0 on 08.10.19.
//  Copyright © 2019 Zap. All rights reserved.
//
import Foundation

public final class OnionConnecter {
    public enum OnionError: Error {
        case connectionError
    }

    private var progress: ((Int) -> Void)?
    private var completion: ((Result<URLSessionConfiguration, OnionError>) -> Void)?

    public init() {}

    public func start(socksPort: Int, progress: ((Int) -> Void)?, completion: @escaping (Result<URLSessionConfiguration, OnionError>) -> Void) {
        self.progress = progress
        self.completion = completion
        OnionManager.shared.startTor(socksPort: socksPort, delegate: self)
    }
}

extension OnionConnecter: OnionManagerDelegate {
    func torConnProgress(_ progress: Int) {
        print("\(progress)")
        self.progress?(progress)
    }

    func torConnFinished(socksPort: Int, configuration: URLSessionConfiguration) {
        // TODO: this is a fix for Tor 400.5.2. Can be removed once there is a
        // new release on github.
        configuration.connectionProxyDictionary = [
            kCFProxyTypeKey: kCFProxyTypeSOCKS,
            kCFStreamPropertySOCKSProxyHost: "localhost",
            kCFStreamPropertySOCKSProxyPort: socksPort
        ]
        if #available(iOSApplicationExtension 13.0, *), #available(iOS 13.0, *) {
            configuration.tlsMaximumSupportedProtocolVersion = .TLSv12
        } else {
            configuration.tlsMinimumSupportedProtocol = .tlsProtocol12
        }
        completion?(.success(configuration))
    }

    func torConnError() {
        print("torConnError")
        completion?(.failure(.connectionError))
    }
}
