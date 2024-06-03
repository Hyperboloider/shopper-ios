//
//  MirrorSocketData.swift
//  Shopper
//
//  Created by Illia Kniaziev on 25.04.2024.
//

import Foundation
import SocketIO

protocol MirrorSocketData: Codable, SocketData {}

enum MirrorSocketDataEncodingError: Error {
    case unknown
}

extension MirrorSocketData {
    func socketRepresentation() throws -> any SocketData {
        let data = try JSONEncoder().encode(self)
        guard let result = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? [String: Any]
        else { throw MirrorSocketDataEncodingError.unknown }
        return result
    }
}
