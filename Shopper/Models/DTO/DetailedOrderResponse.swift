//
//  DetailedOrderResponse.swift
//  Shopper
//
//  Created by Гіяна Князєва on 24.12.2022.
//

import Foundation

struct DetailedOrderResponse: Decodable, Identifiable {
    let id: String
    let creationDate: Date
    let creatorId: String
    let products: [DetailedOrderItemResponse]
}

struct DetailedOrderItemResponse: Decodable, Identifiable {
    let quantity: Double
    let product: ProductResponse
    
    var id: String { product.id }
}
