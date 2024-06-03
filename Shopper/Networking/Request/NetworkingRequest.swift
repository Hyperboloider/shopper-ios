//
//  NetworkingRequest.swift
//  Shopper
//
//  Created by Illia Kniaziev on 03.12.2022.
//

import Combine
import Foundation

typealias Headers = [String : String]
typealias Body = [String : String]

enum RequestError: Error {
    
    case failedToCreateUrl
 
}

enum HTTPMethod: String {
    
    case delete = "DELETE"
    
    case get = "GET"
    
    case patch = "PATCH"
    
    case post = "POST"
    
    case put = "PUT"
    
}

protocol NetworkingRequest {
    
    associatedtype ReturnType
    
    var endpoint: String { get }
    
    var method: HTTPMethod { get }
    
    var headers: Headers { get }
    
    var queryItems: [URLQueryItem]? { get }
    
    var body: Data? { get }
    
    var authorizationStrategy: AuthorizationStrategy { get }
    
    func perform(byService service: NetworkingServiceProtocol) -> AnyPublisher<ReturnType, Error>
    
    func buildRequest() throws -> URLRequest
    
}
