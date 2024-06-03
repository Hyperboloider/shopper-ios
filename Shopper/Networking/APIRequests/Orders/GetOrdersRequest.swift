//
//  GetOrdersRequest.swift
//  Shopper
//
//  Created by Гіяна Князєва on 23.12.2022.
//

import Foundation

final class GetOrdersRequest: DecodableRequest<OrdersResponse> {
    
    init(id: String) {
        let endpoint = APIPath.Order.orders(byUserId: id)
        super.init(endpoint: endpoint, method: .get, authorizationStrategy: AuthorizedRequestStrategy(), decoder: .apiDateHandlingInstance)
    }
    
}
