//
//  DecodableRequest.swift
//  Shopper
//
//  Created by Illia Kniaziev on 03.12.2022.
//

import Combine
import Foundation

class PlainRequest: NetworkingRequest {
    
    typealias ReturnType = Never

    var endpoint: String
    var method: HTTPMethod
    var headers: Headers
    var queryItems: [URLQueryItem]?
    var body: Data?
    var authorizationStrategy: AuthorizationStrategy
    var decoder: JSONDecoder
    
    init(
        endpoint: String,
        method: HTTPMethod,
        headers: Headers = [:],
        queryItems: [URLQueryItem]? = nil,
        body: Data?,
        authorizationStrategy: AuthorizationStrategy,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.endpoint = endpoint
        self.method = method
        self.headers = headers
        self.queryItems = queryItems
        self.body = body
        self.authorizationStrategy = authorizationStrategy
        self.decoder = decoder
    }
    
    init(
        endpoint: String,
        method: HTTPMethod,
        headers: Headers = [:],
        queryItems: [URLQueryItem]? = nil,
        body: Body? = nil,
        authorizationStrategy: AuthorizationStrategy,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.endpoint = endpoint
        self.method = method
        self.headers = headers
        self.queryItems = queryItems
        self.body = try? JSONEncoder().encode(body)
        self.authorizationStrategy = authorizationStrategy
        self.decoder = decoder
    }
    
    func perform(byService service: NetworkingServiceProtocol) -> AnyPublisher<Never, Error> {
        service.request(self)
            .ignoreOutput()
            .eraseToAnyPublisher()
    }
    
    func buildRequest() throws -> URLRequest {
        guard var components = URLComponents(string: endpoint) else { throw RequestError.failedToCreateUrl }
        
        components.queryItems = queryItems
        
        guard let url = components.url else { throw RequestError.failedToCreateUrl }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        request.cachePolicy = .reloadIgnoringCacheData

        if method != .get {
            request.httpBody = body
        }
        
        return request
    }
    
}
