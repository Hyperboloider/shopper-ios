//
//  ServerToClientEventType.swift
//  Shopper
//
//  Created by Illia Kniaziev on 25.04.2024.
//

import Foundation

enum ServerToClientEventType: String, MirrorSocketData {
    case update
}

enum ClientToServerEventType: String, MirrorSocketData {
    case join
}
