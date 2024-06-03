//
//  GetDetailedShoppingListRequest.swift
//  Shopper
//
//  Created by Illia Kniaziev on 26.04.2024.
//

import Foundation

final class GetDetailedShoppingListRequest: DecodableRequest<DetailedShoppingListResponse> {
    
    init(listId: String) {
        let endpoint = APIPath.ShoppingList.shoppingList(byId: listId)
        super.init(endpoint: endpoint, method: .get, authorizationStrategy: AuthorizedRequestStrategy(), decoder: .apiDateHandlingInstance)
    }
    
}
