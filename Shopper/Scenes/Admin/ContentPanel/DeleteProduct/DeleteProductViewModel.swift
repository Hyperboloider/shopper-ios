//
//  DeleteProductViewModel.swift
//  Shopper
//
//  Created by Гіяна Князєва on 22.12.2022.
//

import Foundation
import Combine

final class DeleteProductViewModel: SearchViewModel {
    
    @Published var result: ProductResponse?
    @Published var upc = ""
    @Published var canSubmit = false
    @Published var isAlertShown = false
    
    override init(networkingService: NetworkingServiceProtocol) {
        super.init(networkingService: networkingService)
        subscribeOnSearch()
        subscribeOnInput()
    }
    
    func submit() {
        guard networkingState != .waiting else { return }
        
        networkingState = .waiting
        DeleteProductRequest(upc: result?.upc ?? upc)
            .perform(byService: networkingService)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                if let statusCode = self?.getStatusCodeIfPossible(from: completion), statusCode == 404 {
                    self?.isAlertShown = true
                }
                
                self?.handleCompletion(completion)
            }, receiveValue: { _ in })
            .store(in: &subscriptions)
    }
    
}

// MARK: - Validation
private extension DeleteProductViewModel {
    func subscribeOnInput() {
        subscribeOnUpc()
        subscribeOnResult()
        
        Publishers
            .CombineLatest($result, $upc)
            .sink { [weak self] result, upc in
                
                self?.canSubmit = result != nil || !upc.isEmpty
            }
            .store(in: &subscriptions)
    }
    
    func subscribeOnUpc() {
        $upc
            .filter { !$0.isEmpty }
            .sink { [weak self] _ in
                self?.searchQuery = ""
                self?.result = nil
            }
            .store(in: &subscriptions)
    }
    
    func subscribeOnResult() {
        $result
            .compactMap { $0 }
            .sink { [weak self] _ in
                self?.upc = ""
            }
            .store(in: &subscriptions)
    }
}
