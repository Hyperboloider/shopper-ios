//
//  OrderResponse.swift
//  Shopper
//
//  Created by Гіяна Князєва on 23.12.2022.
//

import Foundation

typealias OrdersResponse = [OrderResponse]

struct OrderResponse: Decodable, Identifiable {
    let id: String
    let creationDate: Date
    let creatorId: String
    let products: [OrderItemResponse]
}

struct OrderItemResponse: Decodable {
    let quantity: Double
    let product: String
}
