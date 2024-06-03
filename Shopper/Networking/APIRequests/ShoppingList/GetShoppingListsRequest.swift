//
//  GetShoppingListsRequest.swift
//  Shopper
//
//  Created by Illia Kniaziev on 26.04.2024.
//

import Foundation

final class GetShoppingListsRequest: DecodableRequest<[ShoppingListResponse]> {
    
    init() {
        let endpoint = APIPath.ShoppingList.shoppingLists
        super.init(endpoint: endpoint, method: .get, authorizationStrategy: AuthorizedRequestStrategy(), decoder: .apiDateHandlingInstance)
    }
    
}
