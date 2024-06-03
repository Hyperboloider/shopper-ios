//
//  DeleteShoppingListRequest.swift
//  Shopper
//
//  Created by Illia Kniaziev on 26.04.2024.
//

import Foundation

final class DeleteShoppingListRequest: PlainRequest {
    init(id: String) {
        let endpoint = APIPath.ShoppingList.deleteList(withId: id)
        super.init(endpoint: endpoint, method: .delete, authorizationStrategy: AuthorizedRequestStrategy())
    }
}
