//
//  CartItem.swift
//  Shopper
//
//  Created by Illia Kniaziev on 17.12.2023.
//

import Foundation
import RealmSwift

final class CartItem: Object, ObjectKeyIdentifiable {
    
    @Persisted(primaryKey: true) var upc: String
    @Persisted var quantity: Double
    
    convenience init(shoppingCartItem: ShoppingCartItem) {
        self.init()
        self.upc = shoppingCartItem.product.upc
        self.quantity = shoppingCartItem.amount
    }
    
}
