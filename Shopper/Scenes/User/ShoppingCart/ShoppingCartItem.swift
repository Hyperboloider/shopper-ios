//
//  ShoppingCartItem.swift
//  Shopper
//
//  Created by Illia Kniaziev on 19.12.2022.
//

import Foundation

struct ShoppingCartItem: Identifiable, Hashable {
    let product: ProductResponse
    var amount: Double
    
    var id: String { product.id }

    init(product: ProductResponse, quantity: Double? = nil) {
        self.product = product
        if let quantity {
            self.amount = quantity
        } else {
            self.amount = product.isPricePerKilo ? 0.1 : 1
        }
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(amount)
    }

    static func == (lhs: ShoppingCartItem, rhs: ShoppingCartItem) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}
