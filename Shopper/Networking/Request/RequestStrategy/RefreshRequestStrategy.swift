//
//  RefreshRequestStrategy.swift
//  Shopper
//
//  Created by Illia Kniaziev on 18.12.2022.
//

import Combine
import Foundation

final class RefreshRequestStrategy: AuthorizationStrategy {
    
    func dataTaskPublisher(
        withConfig config: URLSessionConfiguration,
        forRequest request: URLRequest,
        usingMappingExpression expression: @escaping (Data, URLResponse) throws -> Data
    ) -> AnyPublisher<Data, Error> {
        guard let jwt = JWTHelper.restoreJWT() else {
            return Fail(outputType: Data.self, failure: NetworkingService.NetworkingError.incompleteJWTResponse)
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
        var authenticatedRequest = request
        authenticatedRequest.allHTTPHeaderFields?["Authorization"] = "Bearer \(jwt.refreshToken)"
        
        return UnauthorizedRequestStrategy()
            .dataTaskPublisher(
                withConfig: config,
                forRequest: authenticatedRequest,
                usingMappingExpression: expression
            )
            .eraseToAnyPublisher()
    }
    
}
