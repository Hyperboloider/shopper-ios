//
//  CreateShoppingListRequest.swift
//  Shopper
//
//  Created by Illia Kniaziev on 27.04.2024.
//

import Foundation

final class CreateShoppingListRequest: DecodableRequest<ShoppingListResponse> {
    
    init(body: Body) {
        let endpoint = APIPath.ShoppingList.shoppingLists
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

extension CreateShoppingListRequest {
    
    struct Body: Codable {
        let name: String
        let products: [CreateShoppingListItem]
    }
    
    struct CreateShoppingListItem: Codable {
        let quantity: Double
        let product: String
    }

}
