//
//  FindProductViewModel.swift
//  Shopper
//
//  Created by Illia Kniaziev on 12.05.2024.
//

import Foundation
import Combine

final class FindProductViewModel: SearchViewModel {
    
    @Published var result: ProductResponse?
    @Published var upc = ""
    @Published var canSubmit = false
    @Published var isAlertShown = false
    private let onSubmit: (String) -> Void
    
    init(networkingService: NetworkingServiceProtocol, onSubmit: @escaping (String) -> Void) {
        self.onSubmit = onSubmit
        super.init(networkingService: networkingService)
        subscribeOnSearch()
        subscribeOnInput()
    }
    
    func submit() {
        let upc = result?.upc ?? upc
        guard !upc.isEmpty else { return }
        onSubmit(upc)
    }
    
}

// MARK: - Validation
private extension FindProductViewModel {
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
