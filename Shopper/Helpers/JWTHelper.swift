//
//  JWTHelper.swift
//  Shopper
//
//  Created by Illia Kniaziev on 18.12.2022.
//

import Foundation
import SwiftKeychainWrapper

extension KeychainWrapper.Key {
    static let accessToken: KeychainWrapper.Key = "accessToken"
    static let refreshToken: KeychainWrapper.Key = "refreshToken"
    static let accessTokenExp: KeychainWrapper.Key = "accessTokenExp"
    static let refreshTokenExp: KeychainWrapper.Key = "refreshTokenExp"
}

final class JWTHelper {
    
    static func saveJWT(from jwt: JWTData) {
        KeychainWrapper.standard[.accessToken] = jwt.accessToken
        KeychainWrapper.standard[.refreshToken] = jwt.refreshToken
        KeychainWrapper.standard[.accessTokenExp] = jwt.accessTokenExp
        KeychainWrapper.standard[.refreshTokenExp] = jwt.refreshTokenExp
    }
    
    static func restoreJWT() -> JWTData? {
        guard let accessToken: String = KeychainWrapper.standard[.accessToken],
              let refreshToken: String = KeychainWrapper.standard[.refreshToken],
              let accessTokenExp: String = KeychainWrapper.standard[.accessTokenExp],
              let refreshTokenExp: String = KeychainWrapper.standard[.refreshTokenExp]
        else { return nil }
        
        return JWTData(accessToken: accessToken, refreshToken: refreshToken, accessTokenExp: accessTokenExp, refreshTokenExp: refreshTokenExp)
    }
    
    static func getJwtMetadata(token: String) -> JWTMetadata? {
        let segments = token.components(separatedBy: ".")
        var base64String = segments[1]

        let requiredLength = Int(4 * ceil(Float(base64String.count) / 4.0))
        let nbrPaddings = requiredLength - base64String.count
       
        if nbrPaddings > 0 {
           let padding = String().padding(toLength: nbrPaddings, withPad: "=", startingAt: 0)
           base64String = base64String.appending(padding)
        }
        
        base64String = base64String.replacingOccurrences(of: "-", with: "+")
        base64String = base64String.replacingOccurrences(of: "_", with: "/")
        
        guard let decodedData = Data(base64Encoded: base64String, options: Data.Base64DecodingOptions(rawValue: UInt(0)))
        else { return nil }

        return try? JSONDecoder().decode(JWTMetadata.self, from: decodedData)
    }
    
    static func removeToken() {
        KeychainWrapper.standard.remove(forKey: .accessToken)
        KeychainWrapper.standard.remove(forKey: .refreshToken)
        KeychainWrapper.standard.remove(forKey: .accessTokenExp)
        KeychainWrapper.standard.remove(forKey: .refreshTokenExp)
    }
    
    static var userNeedsRefresh: Bool {
        guard let token = JWTHelper.restoreJWT(),
              let accessTokenExp = Double(token.accessTokenExp),
              !userNeedsAuthorization
        else { return false }
        
        let currentUnixSeconds = Date().timeIntervalSince1970
        
        return currentUnixSeconds > accessTokenExp
    }
    
    static var userNeedsAuthorization: Bool {
        guard let token = JWTHelper.restoreJWT(),
              let refreshTokenExp = Double(token.refreshTokenExp)
        else { return true }
        
        let currentUnixSeconds = Date().timeIntervalSince1970
        
        return currentUnixSeconds > refreshTokenExp
    }
    
}
