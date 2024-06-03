//
//  NetworkingService.swift
//  Shopper
//
//  Created by Illia Kniaziev on 03.12.2022.
//

import Combine
import Foundation

final class NetworkingService: NetworkingServiceProtocol, ObservableObject {
    
    enum NetworkingError: Error, LocalizedError {
        case error(Error)
        case noResponse
        case unacceptableStatusCode(Int, String)
        case incompleteJWTResponse
        
        var localizedDescription: String {
            switch self {
            case .error(let error):
                error.localizedDescription
            case .noResponse:
                "No response. Check your internet."
            case .unacceptableStatusCode(_, let string):
                string
            case .incompleteJWTResponse:
                "Check your internet!"
            }
        }
    }
    
    var requestTimeout: TimeInterval = 30
    
    private let errorDecoder: JSONDecoder = JSONDecoder()
    
    func request<T>(_ request: T) -> AnyPublisher<Data, Error> where T : NetworkingRequest {
        do {
            let urlRequest = try request.buildRequest()
            let config = URLSessionConfiguration.default
            config.timeoutIntervalForRequest = requestTimeout
            print(request.endpoint)
            print(request.headers)
            return request
                .authorizationStrategy
                .dataTaskPublisher(
                    withConfig: config,
                    forRequest: urlRequest,
                    usingMappingExpression: handleResponse(_:_:)
                )
        } catch let e {
            return Fail(outputType: Data.self, failure: NetworkingError.error(e))
                .receive(on: RunLoop.main)
                .eraseToAnyPublisher()
        }
    }
    
    private func handleResponse(_ data: Data, _ response: URLResponse) throws -> Data {
        guard let response = response as? HTTPURLResponse
        else { throw NetworkingError.noResponse }
        print(String(data: data, encoding: .utf8) ?? "-1")
        if !(200...299 ~= response.statusCode) {
            let errorMessage: String
            if let error = try? self.errorDecoder.decode(ErrorResponse.self, from: data) {
                errorMessage = error.message?.joined(separator: "; ") ?? ""
                print("🔴 Error occured: \(error)")
            } else {
                print("🔴", String(data: data, encoding: .utf8) ?? "NONE")
                errorMessage = ""
            }
            
            throw NetworkingError.unacceptableStatusCode(response.statusCode, errorMessage)
        }
        
        return data
    }
    
}
