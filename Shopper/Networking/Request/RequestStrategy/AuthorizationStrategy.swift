//
//  AuthorizationStrategy.swift
//  Shopper
//
//  Created by Illia Kniaziev on 11.12.2022.
//

import Combine
import Foundation

protocol AuthorizationStrategy {
    
    func dataTaskPublisher(
        withConfig config: URLSessionConfiguration,
        forRequest request: URLRequest,
        usingMappingExpression expression: @escaping (Data, URLResponse) throws -> Data
    ) -> AnyPublisher<Data, Error>
    
}
