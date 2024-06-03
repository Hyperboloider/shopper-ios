//
//  CartViewModel.swift
//  Shopper
//
//  Created by Гіяна Князєва on 20.12.2022.
//

import Foundation
import Combine

final class CartViewModel: SearchViewModel {
    
    struct EvaluatedCart: Hashable {
        let price: Double
        let items: [ShoppingCartItem]
        
        init(cart: [AdjustedProductResponse]) {
            price = cart.reduce(into: 0) { $0 += $1.product.price * $1.quantity }
            items = cart
                .map { ShoppingCartItem(product: $0.product, quantity: $0.quantity) }
                .sorted { $0.product.name < $1.product.name }
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(items.hashValue)
        }
    }
    
    // MARK: - Basket adjastment properties
    @Published var isDynamicAdjastmentEnabled = false
    /// Double needed to bind to a Slider
    @Published var selectedSimilarCartIndex = 0.0
    @Published var similarCarts: [EvaluatedCart] = []
    
    // TODO: disable slider when fetching, show skeleton placeholder, debounce requests, ignore duplicates!
    
    override init(networkingService: NetworkingServiceProtocol) {
        super.init(networkingService: networkingService)
        subscribeOnSearch()
    }
    
    func sendOrder(purchases: [ShoppingCartItem], completion: @escaping () -> Void) {
        guard !purchases.isEmpty, networkingState != .waiting else { return }
        
        networkingState = .waiting
        DispatchQueue.global(qos: .userInitiated).async { [self] in
            let products = purchases.map { CreateOrderRequest.OrderItem(quantity: $0.amount, product: $0.product.id) }
            CreateOrderRequest(body: CreateOrderRequest.Body(products: products))
                .perform(byService: networkingService)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { [weak self] result in
                    self?.handleCompletion(result)
                    if case .finished = result {
                        completion()
                    }
                }, receiveValue: { _ in })
                .store(in: &self.subscriptions)
        }
    }
    
    func fetchSimilarCarts(cart: [ShoppingCartItem]) {
        guard !cart.isEmpty, networkingState != .waiting else { return }
        
        let items = cart.map { SimilarCartRequest.ProductItem(quantity: $0.amount, product: $0.product.id) }
        
        networkingState = .waiting
        SimilarCartRequest(cart: items)
            .perform(byService: networkingService)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.networkingState = .failure(error)
                }
            } receiveValue: { [weak self] suggestedCarts in
                let initialProducts = cart.map { AdjustedProductResponse(quantity: $0.amount, product: $0.product) }
                let originalCart = EvaluatedCart(cart: initialProducts)
                let originalCartHash = originalCart.hashValue
                
                let similarCarts = ([originalCart] + suggestedCarts
                    .map(EvaluatedCart.init))
                    .sorted { $0.price < $1.price }
                self?.similarCarts = similarCarts
                self?.networkingState = .none
                
                let index = similarCarts.firstIndex { $0.hashValue == originalCartHash } ?? 0
                self?.selectedSimilarCartIndex = Double(index)
            }
            .store(in: &subscriptions)
    }
    
}
