//
//  NetworkReachability.swift
//  NASA-APOD
//
//

import Foundation

class NetworkReachability {
    //MARK: - Properties

    /// Reachability instance for validating network connectivity
    var reachability: Reachability?

    //MARK: - Initializers

    init() {
        reachability = try? Reachability(hostname: Configuration.baseURL)
        startNotifier()
    }

    //MARK: - Functions

    func startNotifier() {
        do {
            try reachability?.startNotifier()
        } catch {
            return
        }
    }

    func stopNotifier() {
        reachability?.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: nil)
        reachability = nil
    }

    //MARK: - deinit

    deinit {
        stopNotifier()
    }
}
