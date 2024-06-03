//
//  ErrorResponse.swift
//  Shopper
//
//  Created by Illia Kniaziev on 18.12.2022.
//

import Foundation

struct ErrorResponse: Decodable, Error {
    let statusCode: Int
    let message: [String]?
    let error: String?
    
    enum CodingKeys: CodingKey {
        case statusCode
        case message
        case error
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.statusCode = try container.decode(Int.self, forKey: .statusCode)
        
        if let strMessage = try? container.decodeIfPresent(String.self, forKey: .message) {
            self.message = [strMessage]
        } else if let arrMessage = try? container.decodeIfPresent([String].self, forKey: .message) {
            self.message = arrMessage
        } else {
            self.message = nil
        }
        
        self.error = try container.decodeIfPresent(String.self, forKey: .error)
    }
}
