//
//  OptimisationRequest.swift
//  Shopper
//
//  Created by Гіяна Князєва on 29.12.2022.
//

import Foundation

final class OptimisationRequest: DecodableRequest<Cart> {
    
    init(body: Body) {
        let endpoint = APIPath.Search.minimax
        let headers = ["Content-Type" : "application/json"]
        let body = try? JSONEncoder().encode(body)
        super.init(endpoint: endpoint, method: .post, headers: headers, body: body, authorizationStrategy: AuthorizedRequestStrategy())
    }
    
}

extension OptimisationRequest {
    
    struct Body: Encodable {
        let categories: [String]
        let options: [OptimisationOption]
    }
    
    struct OptimisationOption: Encodable {
        let isMax: Bool
        let option: String
    }
    
}
