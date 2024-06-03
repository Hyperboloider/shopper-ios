//
//  KickUserRequest.swift
//  Shopper
//
//  Created by Illia Kniaziev on 12.05.2024.
//

import Foundation

final class KickUserRequest: PlainRequest {
    
    init(listId: String, userId: String) {
        let endpoint = APIPath.ShoppingList.kickUser(fromList: listId, withUserId: userId)
        super.init(
            endpoint: endpoint,
            method: .patch,
            authorizationStrategy: AuthorizedRequestStrategy()
        )
    }
    
}
