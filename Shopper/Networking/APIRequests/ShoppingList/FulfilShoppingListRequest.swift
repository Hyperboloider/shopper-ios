//
//  FulfilShoppingListRequest.swift
//  Shopper
//
//  Created by Illia Kniaziev on 05.05.2024.
//

import Foundation

final class FulfilShoppingListRequest: PlainRequest {
    
    init(body: Body) {
        let endpoint = APIPath.ShoppingList.fulfilShoppingLists
        let headers = ["Content-Type" : "application/json"]
        let body = try? JSONEncoder().encode(body)
        
        super.init(
            endpoint: endpoint,
            method: .post,
            headers: headers,
            body: body,
            authorizationStrategy: AuthorizedRequestStrategy(),
            decoder: .apiDateHandlingInstance
        )
    }
    
}

extension FulfilShoppingListRequest {
    
    struct Body: Codable {
        let listsIds: [String]
        let products: [FulfilShoppingListItem]
    }
    
    struct FulfilShoppingListItem: Codable {
        let quantity: Double
        let product: String
    }
    
}

