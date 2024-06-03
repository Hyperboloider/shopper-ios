//
//  AuthResponse.swift
//  Shopper
//
//  Created by Illia Kniaziev on 18.12.2022.
//

import Foundation

struct AuthResponse: Decodable {
    let accessToken: String
    let refreshToken: String
}
