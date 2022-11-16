//
//  NetworkStatusService.swift
//

import Foundation
import Network

class NetworkStatusService: ObservableObject {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue.global(qos: .background)

    @Published var connected: Bool = true {
        didSet {
            Log(.debug, message: "[NETWORK]: \(connected ? "Connected" : "Disconnected")")
        }
    }
    
    static let shared = NetworkStatusService()

    init() {
        startMonitoring()
    }
    
    func startMonitoring() {
        Log(.debug, message: "[NETWORK]: Start monitoring")
        
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                OperationQueue.main.addOperation {
                    self.connected = true
                    
                    Log(.debug, message: "[NETWORK]: Connected")
                }
            } else {
                OperationQueue.main.addOperation {
                    self.connected = false
                    
                    Log(.debug, message: "[NETWORK]: Not connected")
                }
            }
        }
        
        monitor.start(queue: queue)
    }
    
    func stopMonitoring() {
        Log(.debug, message: "[NETWORK]: Stopped monitoring")
        monitor.pathUpdateHandler = nil
    }
}
