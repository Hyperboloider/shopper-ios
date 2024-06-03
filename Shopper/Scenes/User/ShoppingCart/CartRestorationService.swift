//
//  CartRestorationService.swift
//  Shopper
//
//  Created by Illia Kniaziev on 17.12.2023.
//

import Foundation
import RealmSwift
import Combine

final class CartRestorationService: NetworkingViewModel {
    private let realm = try! Realm()
    private var bag = Set<AnyCancellable>()

    func restoreFromDraft() -> Future<[ShoppingCartItem], Never> {
        let cartItems = realm.objects(CartItem.self)
        var restoredItems = [ShoppingCartItem]()
        
        return Future { [weak self] promise in
            guard let self else { return }
            Publishers
                .MergeMany(cartItems.map { UpcProductRequest(upc: $0.upc).perform(byService: self.networkingService) })
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { _ in
                    promise(.success(restoredItems))
                }, receiveValue: { product in
                    guard let quantity = cartItems.first(where: { $0.upc == product.upc })?.quantity else { return }
                    let shoppingCartItem = ShoppingCartItem(product: product, quantity: quantity)
                    restoredItems.append(shoppingCartItem)
                })
                .store(in: &bag)
        }
    }
    
}
