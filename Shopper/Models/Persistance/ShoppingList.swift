//
//  ShoppingList.swift
//  Shopper
//
//  Created by Illia Kniaziev on 27.04.2024.
//

import Foundation
import RealmSwift

class ShoppingListItem: Object {
    @Persisted var quantity: Double
    @Persisted var bought: Double
    @Persisted var product: String
    
    @Persisted(originProperty: "products") var shoppingList: LinkingObjects<ShoppingList>
}

class ShoppingList: Object, Identifiable {
    @Persisted(primaryKey: true) var id: String
    @Persisted var name: String
    @Persisted var creationDate: Date
    @Persisted var creatorId: String
    @Persisted var users: List<String>
    @Persisted var products: List<ShoppingListItem>
    
    convenience init(response: ShoppingListResponse) {
        self.init()
        self.id = response.id
        self.name = response.name
        self.creationDate = response.creationDate
        self.creatorId = response.creatorId
        self.users.append(objectsIn: response.users)
        response.products.forEach { itemResponse in
            let item = ShoppingListItem()
            item.quantity = itemResponse.quantity
            item.bought = itemResponse.bought
            item.product = itemResponse.product
            self.products.append(item)
        }
    }
    
    func update(with response: ShoppingListResponse) {
        self.name = response.name
        self.creationDate = response.creationDate
        self.creatorId = response.creatorId
        self.users.removeAll()
        self.users.append(objectsIn: response.users)
        
        let existingProductIds = Set(products.map { $0.product })
        let newProductIds = Set(response.products.map { $0.product })
        
        // Remove items that are not in the new products list
        let itemsToRemove = products.filter { !newProductIds.contains($0.product) }
        realm?.delete(itemsToRemove)
        
        // Update existing items or add new items
        response.products.forEach { itemResponse in
            if let existingItem = products.first(where: { $0.product == itemResponse.product }) {
                existingItem.quantity = itemResponse.quantity
                existingItem.bought = itemResponse.bought
            } else {
                let newItem = ShoppingListItem()
                newItem.quantity = itemResponse.quantity
                newItem.bought = itemResponse.bought
                newItem.product = itemResponse.product
                self.products.append(newItem)
            }
        }
    }
    
//
//    override static func primaryKey() -> String? {
//        return "id"
//    }
}
