//
//  GenerateShoppingListInvitationRequest.swift
//  Shopper
//
//  Created by Illia Kniaziev on 27.04.2024.
//

import Foundation

final class GenerateShoppingListInvitationRequest: DecodableRequest<InvitationResponse> {
    
    init(listId: String) {
        let endpoint = APIPath.ShoppingList.generateInvitation(withListId: listId)
        super.init(
            endpoint: endpoint,
            method: .post,
            authorizationStrategy: AuthorizedRequestStrategy()
        )
    }
    
}
