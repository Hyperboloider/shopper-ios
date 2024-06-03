//
//  UpdateShoppingListRequest.swift
//  Shopper
//
//  Created by Illia Kniaziev on 26.04.2024.
//

import Foundation

final class UpdateShoppingListRequest: DecodableRequest<DetailedShoppingListResponse> {
    
    init(listId: String, body: Body) {
        let endpoint = APIPath.ShoppingList.updateList(withId: listId)
        let headers = ["Content-Type" : "application/json"]
        let body = try? JSONEncoder().encode(body)
        
        super.init(
            endpoint: endpoint,
            method: .put,
            headers: headers,
            body: body,
            authorizationStrategy: AuthorizedRequestStrategy(),
            decoder: .apiDateHandlingInstance
        )
    }
    
}

extension UpdateShoppingListRequest {
    
    struct Body: Codable {
        let products: [CreateShoppingListItem]
    }
    
    struct CreateShoppingListItem: Codable {
        let quantity: Double
        let product: String
    }
    
}
