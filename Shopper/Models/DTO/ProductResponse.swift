//
//  ProductResponse.swift
//  Shopper
//
//  Created by Illia Kniaziev on 19.12.2022.
//

import Foundation

typealias Cart = [ProductResponse]

struct ProductResponse: Decodable, Identifiable, Hashable {
    let id: String
    let name: String
    let description: String
    let upc: String
    let pricePerKilo: Double
    let weightPerItem: Double
    let isPricePerKilo: Bool
    let caloriesPer100g: Double
    let protein: Double
    let fat: Double
    let carb: Double
    let category: String
    let imageUrl: String?
    
    var price: Double {
        pricePerKilo * (weightPerItem / 1000)
    }
    
    enum CodingKeys: String, CodingKey {
        case pricePerKilo = "price"

        case id
        case name
        case description
        case upc
        case weightPerItem
        case isPricePerKilo
        case caloriesPer100g
        case protein
        case fat
        case carb
        case category
        case imageUrl
    }
    
    static func == (lhs: ProductResponse, rhs: ProductResponse) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
}
