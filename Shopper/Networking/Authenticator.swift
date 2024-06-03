//
//  Authenticator.swift
//  Shopper
//
//  Created by Illia Kniaziev on 11.12.2022.
//

import Combine
import Foundation

final class Authenticator {
    
    enum AuthError: Error {
        case userNeedsAuthorization
    }
    
    static func tryAuthenticate() -> AnyPublisher<JWTData, Error> {
        print(JWTHelper.userNeedsAuthorization, JWTHelper.userNeedsRefresh)
        if let jwt = JWTHelper.restoreJWT(), !JWTHelper.userNeedsRefresh && !JWTHelper.userNeedsAuthorization {
            return Just(jwt)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        return RefreshRequest()
            .perform(byService: NetworkingService())
            .share()
            .tryMap(transformAuthResponse(_:))
            .retry(1)
            .handleEvents(
                receiveCompletion: { completion in
                    if case .failure(_) = completion {
                        NotificationCenter.default.post(Notification(name: .logOutNotification))
                    }
                })
            .eraseToAnyPublisher()

    }
    
    //MARK: - JWT handling
    static func transformAuthResponse(_ authResponse: AuthResponse) throws -> JWTData {
        guard let accessTokenMetadata = JWTHelper.getJwtMetadata(token: authResponse.accessToken),
              let refreshTokenMetadata = JWTHelper.getJwtMetadata(token: authResponse.refreshToken)
        else { throw NetworkingService.NetworkingError.incompleteJWTResponse }
        
        let accessTokenExp = String(accessTokenMetadata.exp)
        let refreshTokenExp = String(refreshTokenMetadata.exp)
        
        let jwt = JWTData(
            accessToken: authResponse.accessToken,
            refreshToken: authResponse.refreshToken,
            accessTokenExp: accessTokenExp,
            refreshTokenExp: refreshTokenExp
        )
        
        JWTHelper.saveJWT(from: jwt)
        
        return jwt
    }
    
}
