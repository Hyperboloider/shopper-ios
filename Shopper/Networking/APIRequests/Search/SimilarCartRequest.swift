//
//  SimilarCartRequest.swift
//  Shopper
//
//  Created by Гіяна Князєва on 29.12.2022.
//

import Foundation

final class SimilarCartRequest: DecodableRequest<[[AdjustedProductResponse]]> {
    
    init(cart: Body) {
        let endpoint = APIPath.Search.similarCarts
        let headers = ["Content-Type" : "application/json"]
        let body = try? JSONEncoder().encode(cart)
        super.init(endpoint: endpoint, method: .post, headers: headers, body: body, authorizationStrategy: AuthorizedRequestStrategy())
    }
    
}

extension SimilarCartRequest {
    
    typealias Body = [ProductItem]
    
    struct ProductItem: Encodable {
        let quantity: Double
        let product: String
    }
    
}
