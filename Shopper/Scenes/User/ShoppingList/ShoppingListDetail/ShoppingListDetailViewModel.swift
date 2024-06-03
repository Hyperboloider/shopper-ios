//
//  ShoppingListDetailViewModel.swift
//  Shopper
//
//  Created by Illia Kniaziev on 12.05.2024.
//

import Foundation
import Combine
import RealmSwift

final class ShoppingListDetailViewModel: NetworkingViewModel {
    
    struct ProductProgressItem: Identifiable, Hashable {
        var id: String { product.id }
        var product: ShoppingCartItem
        
        let bought: Double
        var amount: Double { product.amount }
    }
    
    let listId: String
    @Published var isEditable: Bool
    @Published var isEditing = false
    @Published var sharedLink: URL?
    @Published var detailedList: DetailedShoppingListResponse?
    @Published var products: [ProductProgressItem] = [
        //        .init(
        //            product: ShoppingCartItem(product: ProductResponse(
        //                id: "jknfwelkf",
        //                name: "Coca-Cola Zero 0.5",
        //                description: "Sugar-free Coke.",
        //                upc: "123445312345",
        //                pricePerKilo: 15.10, weightPerItem: 1,
        //                isPricePerKilo: false,
        //                caloriesPer100g: 0,
        //                protein: 0,
        //                fat: 0,
        //                carb: 0,
        //                category: "fuzzy drinks", imageUrl: "")),
        //            bought: 0.2
        //        )
    ]
    @Published var canUpdate = false
    private var lastSavedProducts: [ProductProgressItem] = []
    private var sub: NotificationToken?
    
    init(networkingService: any NetworkingServiceProtocol, listId: String, isOwnList: Bool) {
        self.listId = listId
        self.isEditable = isOwnList
        super.init(networkingService: networkingService)
        
        let realm = try! Realm()
        sub = realm
            .objects(ShoppingList.self)
            .observe(on: .main) { [weak self] change in
                self?.fetchList()
            }
    }
    
    func fetchList() {
        GetDetailedShoppingListRequest(listId: listId)
            .perform(byService: networkingService)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: handleCompletion) { [weak self] in
                self?.handleResponse($0)
            }
            .store(in: &subscriptions)
    }
    
    func handleDeletion(item: ShoppingCartItem) {
        products.removeAll { $0.id == item.id }
    }
    
    func saveState() {
        lastSavedProducts = products
    }
    
    func resetState() {
        products = lastSavedProducts
    }
    
    func handleEdit() {
        canUpdate = lastSavedProducts.hashValue != products.hashValue && products.isEmpty == false
    }
    
    func handleUpdate() {
        UpdateShoppingListRequest(
            listId: listId,
            body: .init(
                products: products.map({ UpdateShoppingListRequest.CreateShoppingListItem(quantity: $0.amount, product: $0.id) })
            )
        )
        .perform(byService: networkingService)
        .receive(on: DispatchQueue.main)
        .sink(receiveCompletion: handleCompletion) { [weak self] in
            self?.handleResponse($0)
        }
        .store(in: &subscriptions)
    }
    
    func handleAddition(upc: String) {
        networkingState = .waiting
        UpcProductRequest(upc: upc)
            .perform(byService: networkingService)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: handleCompletion) { [weak self] product in
                self?.products.append(
                    .init(
                        product: .init(
                            product: product,
                            quantity: product.isPricePerKilo ? 0.1 : 1
                        ),
                        bought: 0
                    )
                )
                self?.handleEdit()
            }
            .store(in: &subscriptions)
    }
    
    func shareInvitation() {
        GenerateShoppingListInvitationRequest(listId: listId)
            .perform(byService: networkingService)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: handleCompletion) { [weak self] in
                self?.sharedLink = self?.createInvitation(forId: $0.id)
            }
            .store(in: &subscriptions)
    }
    
    private func createInvitation(forId id: String) -> URL? {
        URL(string: "shopper://accept-invitation?id=\(id)")
    }
    
    private func handleResponse(_ list: DetailedShoppingListResponse) {
        detailedList = list
        products = list.products.map {
            ProductProgressItem(
                product: .init(product: $0.product, quantity: $0.quantity),
                bought: $0.bought
            )
        }
    }
}
