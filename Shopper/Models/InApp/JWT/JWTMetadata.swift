//
//  JWTMetadata.swift
//  Shopper
//
//  Created by Illia Kniaziev on 18.12.2022.
//

import Foundation

struct JWTMetadata: Decodable {
    let iat: Int
    let exp: Int
}
