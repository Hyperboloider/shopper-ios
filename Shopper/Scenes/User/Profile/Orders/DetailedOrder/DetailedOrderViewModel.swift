//
//  DetailedOrderViewModel.swift
//  Shopper
//
//  Created by Гіяна Князєва on 24.12.2022.
//

import Foundation

final class DetailedOrderViewModel: NetworkingViewModel {
    
    let orderId: String
    @Published var detailedOrder: DetailedOrderResponse?
    
    init(networkingService: NetworkingServiceProtocol, orderId: String) {
        self.orderId = orderId
        super.init(networkingService: networkingService)
        
        fetchOrder()
    }
    
    func fetchOrder() {
        guard !orderId.isEmpty, networkingState != .waiting else { return }
        
        networkingState = .waiting
        GetDetailedOrderRequest(orderId: orderId)
            .perform(byService: networkingService)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: handleCompletion) { [weak self] details in
                self?.detailedOrder = details
                self?.networkingState = .success
            }
            .store(in: &subscriptions)
    }
    
}
