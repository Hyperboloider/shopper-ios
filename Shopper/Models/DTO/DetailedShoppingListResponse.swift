//
//  DetailedShoppingListResponse.swift
//  Shopper
//
//  Created by Illia Kniaziev on 26.04.2024.
//

import Foundation

struct DetailedShoppingListResponse: Decodable, Hashable {
    let id: String
    let name: String
    let creationDate: Date
    let creatorId: String
    let users: [String]
    let products: [DetailedShoppingListItemResponse]
}

struct DetailedShoppingListItemResponse: Decodable, Identifiable, Hashable {
    var id: String { product.id }
    
    let quantity: Double
    let bought: Double
    let product: ProductResponse
}
