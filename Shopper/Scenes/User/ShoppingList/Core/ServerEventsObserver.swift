//
//  ServerEventsObserver.swift
//  Shopper
//
//  Created by Illia Kniaziev on 07.05.2024.
//

import Foundation
import SocketIO

protocol SocketEventHandler<ParamsType> {
    associatedtype ParamsType: Codable
    
    var name: String { get }
    
    func handleFailure(data: [Any])
    func handleEvent(data: ParamsType, socketAckEmitter: SocketAckEmitter)
}

extension SocketEventHandler {
    func handleFailure(data: [Any]) {
        debugPrint("🔴 failed to parse \(name) event data into \(ParamsType.self)", data)
    }
}

extension SocketIOClient {
    
    private static let decoder = JSONDecoder()
    
    func handleEvents<T>(with handler: some SocketEventHandler<T>) {
        on(handler.name) { data, ack in
            if let decoded = data.first as? T { return handler.handleEvent(data: decoded, socketAckEmitter: ack) }
            guard
                let dictionary = data.first as? [String: Any],
                let data = try? JSONSerialization.data(withJSONObject: dictionary, options: []),
                let decoded = try? SocketIOClient.decoder.decode(T.self, from: data)
            else { return handler.handleFailure(data: data) }
            
            handler.handleEvent(data: decoded, socketAckEmitter: ack)
        }
    }
}

final class EventHandler<T: Codable>: SocketEventHandler {
    let name: String
    let handler: (T) -> Void
    
    init(name: String, handler: @escaping (T) -> Void) {
        self.name = name
        self.handler = handler
    }
    
    func handleEvent(data: T, socketAckEmitter: SocketAckEmitter) {
        handler(data)
        socketAckEmitter.with(true)
    }
}

final class ServerEventsObserver: ObservableObject {
    
    private enum Constants {
        static let endpoint = URL(string: APIPath.WebSocket.path)!
        static let timeoutTime: Double = 3
        static let reconnectTime: Double = 15
    }
    
    var socketId: String? {
        socket.sid
    }
    
    private let manager = SocketManager(socketURL: Constants.endpoint, config: [.log(false), .compress])
    private var isConnected = false
    private var reconnectionTimer: Timer?
    private lazy var socket = manager.defaultSocket
    
//    init() {
//        connect()
//    }
    
    func setHandler(_ handler: any SocketEventHandler) {
        socket.handleEvents(with: handler)
    }
    
    func sendEvent(forName name: String, event: MirrorSocketData) {
        socket.emit(name, event)
    }
    
    private func scheduleReconnect() {
        reconnectionTimer = Timer(timeInterval: Constants.reconnectTime, repeats: false) { [weak self] _ in
            self?.connect()
        }
    }
    
    func connect() {
        socket.disconnect()
        socket.connect(timeoutAfter: Constants.timeoutTime, withHandler: { [weak self] in
            self?.connect()
        })
    }
    
}
