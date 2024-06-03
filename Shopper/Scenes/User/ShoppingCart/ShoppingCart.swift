//
//  ShoppingCart.swift
//  Shopper
//
//  Created by Illia Kniaziev on 19.12.2022.
//

import RealmSwift
import Foundation
import Combine

final class ShoppingCart: ObservableObject {
    
    @Published var isRestoring = false
    @Published var products: [ShoppingCartItem] = [
//        .init(
//            product: .init(
//                id: "507f1f77bcf86cd799439011",
//                name: "Test name here",
//                description: "Descr",
//                upc: "lkdsmf3",
//                pricePerKilo: 100,
//                weightPerItem: 100,
//                isPricePerKilo: false,
//                caloriesPer100g: 3,
//                protein: 3,
//                fat: 3,
//                carb: 3,
//                category: "rrrtest",
//                imageUrl: nil
//            ),
//            quantity: 3.25
//        )
    ]

    private let realm = try! Realm()
    private let cartRestorationService: CartRestorationService
    private var cachedProducts: [ShoppingCartItem] = []
    private var restorationSubscription: AnyCancellable?
    private var restoredOnce = false

    init(cartRestorationService: CartRestorationService) {
        self.cartRestorationService = cartRestorationService
    }
    
    func append(_ product: ProductResponse, quantity: Double? = nil) {
        if let itemIndex = findIndex(forProduct: product) {
            products[itemIndex].amount += products[itemIndex].product.isPricePerKilo ? 0.1 : 1
            return
        }
        
        products.append(ShoppingCartItem(product: product))
        saveToDraft()
    }
    
    func findItem(byUpc upc: String) -> ShoppingCartItem? {
        return products.first(where: { $0.product.upc == upc })
    }
    
    func delete(item: ShoppingCartItem) {
        guard let index = findIndex(forProduct: item.product) else {
            return
        }
        
        products.remove(at: index)
        saveToDraft()
    }
    
    func saveToDraft() {
        try! realm.write {
            realm.objects(CartItem.self).forEach {
                realm.delete($0)
            }
            
            let cartItems = products.map { CartItem(shoppingCartItem: $0) }
            realm.add(cartItems, update: .modified)
        }
    }
    
    func restoreFromDraft() {
        guard restoredOnce == false else { return }
        isRestoring = true
        restorationSubscription = cartRestorationService
            .restoreFromDraft()
            .sink { [weak self] items in
                self?.products = items
                self?.restoredOnce = true
                self?.isRestoring = false
            }
    }
    
    func cacheItems() {
        cachedProducts = products
    }
    
    func restoreItems() {
        products = cachedProducts
    }
    
    func removeAll() {
        products.removeAll()
        
        let realmObject = realm.objects(CartItem.self)
        realm.writeAsync {
            self.realm.delete(realmObject)
        }
    }
    
    private func findIndex(forProduct product: ProductResponse) -> Int? {
        return products.firstIndex(where: { $0.product.id == product.id })
    }
    
}
