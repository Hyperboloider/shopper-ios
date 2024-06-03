//
//  OrdersViewModel.swift
//  Shopper
//
//  Created by Гіяна Князєва on 24.12.2022.
//

import Foundation

final class OrdersViewModel: NetworkingViewModel {
    
    // TODO: PAGINATION
    @Published var orders: [OrderResponse] = [OrderResponse]()
    @Published var userId: String
    @Published var lastUsedId: String = ""
    let shouldShowInputPrompt: Bool
    
    init(
        networkingService: NetworkingServiceProtocol,
        initialUserId: String
    ) {
        self.userId = initialUserId
        self.shouldShowInputPrompt = false
        super.init(networkingService: networkingService)
        fetchOrders()
    }
    
    init(
        networkingService: NetworkingServiceProtocol,
        shouldShowInputPrompt: Bool
    ) {
        self.userId = ""
        self.shouldShowInputPrompt = shouldShowInputPrompt
        super.init(networkingService: networkingService)
    }
    
    func fetchOrders() {
        guard !userId.isEmpty, networkingState != .waiting else { return }
        
        lastUsedId = userId
        networkingState = .waiting
        GetOrdersRequest(id: userId)
            .perform(byService: networkingService)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: handleCompletion) { [weak self] orders in
                self?.orders = orders.sorted { $0.creationDate > $1.creationDate }
            }
            .store(in: &subscriptions)
    }
    
}
