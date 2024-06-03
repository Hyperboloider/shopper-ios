//
//  JWTData.swift
//  Shopper
//
//  Created by Illia Kniaziev on 18.12.2022.
//

import Foundation

struct JWTData {
    let accessToken: String
    let refreshToken: String
    var accessTokenExp: String
    var refreshTokenExp: String
}
