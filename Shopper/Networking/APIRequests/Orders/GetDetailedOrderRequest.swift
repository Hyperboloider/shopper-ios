//
//  GetDetailedOrderRequest.swift
//  Shopper
//
//  Created by Гіяна Князєва on 24.12.2022.
//

import Foundation

final class GetDetailedOrderRequest: DecodableRequest<DetailedOrderResponse> {
    
    init(orderId: String) {
        let endpoint = APIPath.Order.orders(byOrderId: orderId)
        super.init(endpoint: endpoint, method: .get, authorizationStrategy: AuthorizedRequestStrategy(), decoder: .apiDateHandlingInstance)
    }
    
}
