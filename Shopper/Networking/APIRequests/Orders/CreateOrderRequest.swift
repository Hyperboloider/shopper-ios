//
//  CreateOrderRequest.swift
//  Shopper
//
//  Created by Гіяна Князєва on 23.12.2022.
//

import Foundation

final class CreateOrderRequest: PlainRequest {
    
    init(body: Body) {
        let endpoint = APIPath.Order.orders
        let headers = ["Content-Type" : "application/json"]
        let body = try? JSONEncoder().encode(body)
        
        super.init(endpoint: endpoint, method: .post, headers: headers, body: body, authorizationStrategy: AuthorizedRequestStrategy())
    }
    
}

extension CreateOrderRequest {
    
    struct Body: Encodable {
        let products: [OrderItem]
    }
    
    struct OrderItem: Encodable {
        let quantity: Double
        let product: String
    }
    
}
