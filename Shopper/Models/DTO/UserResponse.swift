//
//  UserResponse.swift
//  Shopper
//
//  Created by Illia Kniaziev on 18.12.2022.
//

import Foundation

struct UserResponse: Decodable, Hashable {
    
    enum Role: String, Decodable {
        case user = "USER"
        case admin = "ADMIN"
    }
    
    let id: String
    let firstName: String
    let lastName: String
    let email: String
    let roles: [Role]
    
    var isAdmin: Bool { roles.contains(.admin) }
}
