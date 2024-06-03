//
//  NetworkingServiceProtocol.swift
//  Shopper
//
//  Created by Illia Kniaziev on 03.12.2022.
//

import Combine
import Foundation

protocol NetworkingServiceProtocol {
    
    var requestTimeout: TimeInterval { get }
    
    func request<T: NetworkingRequest>(_ request: T) -> AnyPublisher<Data, Error>
    
}
