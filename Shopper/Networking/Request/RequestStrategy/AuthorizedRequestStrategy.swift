//
//  AuthorizedRequestStrategy.swift
//  Shopper
//
//  Created by Illia Kniaziev on 11.12.2022.
//

import Combine
import Foundation

final class AuthorizedRequestStrategy: AuthorizationStrategy {
    
    func dataTaskPublisher(
        withConfig config: URLSessionConfiguration,
        forRequest request: URLRequest,
        usingMappingExpression expression: @escaping (Data, URLResponse) throws -> Data
    ) -> AnyPublisher<Data, Error> {
        return Authenticator
            .tryAuthenticate()
            .flatMap { jwt -> AnyPublisher<Data, Error> in
                var authenticatedRequest = request
                authenticatedRequest.allHTTPHeaderFields?["Authorization"] = "Bearer \(jwt.accessToken)"
                
                return UnauthorizedRequestStrategy().dataTaskPublisher(
                    withConfig: config,
                    forRequest: authenticatedRequest,
                    usingMappingExpression: expression
                )
            }
            .eraseToAnyPublisher()
    }
    
}
