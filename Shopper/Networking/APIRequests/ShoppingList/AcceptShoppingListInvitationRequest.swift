//
//  AcceptShoppingListInvitationRequest.swift
//  Shopper
//
//  Created by Illia Kniaziev on 27.04.2024.
//

import Foundation

final class AcceptShoppingListInvitationRequest: DecodableRequest<ShoppingListResponse> {
    
    init(invitationId: String) {
        let endpoint = APIPath.ShoppingList.acceptInvitation(withId: invitationId)
        super.init(
            endpoint: endpoint,
            method: .post,
            authorizationStrategy: AuthorizedRequestStrategy(),
            decoder: .apiDateHandlingInstance
        )
    }
    
}
