//
//  ShoppingList.swift
//  Shopper
//
//  Created by Illia Kniaziev on 26.04.2024.
//

import Foundation

struct ShoppingListResponse: Decodable {
    let id: String
    let name: String
    let creationDate: Date
    let creatorId: String
    let users: [String]
    let products: [ShoppingListItemResponse]
}

struct ShoppingListItemResponse: Decodable {
    let quantity: Double
    let product: String
    let bought: Double
}
