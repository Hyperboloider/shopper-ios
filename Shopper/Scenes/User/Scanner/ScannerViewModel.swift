//
//  ScannerViewModel.swift
//  Shopper
//
//  Created by Illia Kniaziev on 19.12.2022.
//

import VisionKit
import Combine

final class ScannerViewModel: NetworkingViewModel {
    
    @Published var recentlyScannedCode: String = ""
    @Published var pendingRequests = 0
    
    private var shoppingCart: ShoppingCart
    
    init(networkingService: NetworkingServiceProtocol, shoppingCart: ShoppingCart) {
        self.shoppingCart = shoppingCart
        super.init(networkingService: networkingService)
        subsribeOnScnner()
    }
}

// MARK: - UPC Search
private extension ScannerViewModel {
    func handleResponse(_ response: ProductResponse) {
        DispatchQueue.main.async {
            self.shoppingCart.append(response)
        }
    }
    
    func requestProduct(withUpc upc: String) {
        if let alreadyAdded = self.shoppingCart.findItem(byUpc: upc)?.product {
            handleResponse(alreadyAdded)
            return
        }
        
        pendingRequests += 1
        UpcProductRequest(upc: upc)
            .perform(byService: self.networkingService)
            .map {
                DispatchQueue.main.async {
                    self.pendingRequests = max((self.pendingRequests - 1), 0)
                }
                return $0
            }
            .sink { [weak self] completion in
                if case .failure(_) = completion {
                    self?.pendingRequests = max(((self?.pendingRequests ?? 0) - 1), 0)
                    HapticsFeedbackGenerator.genereteFeedback(.error)
                }
            } receiveValue: { [weak self] product in
                self?.handleResponse(product)
            }
            .store(in: &subscriptions)
    }
    
    func subsribeOnScnner() {
        $recentlyScannedCode
            .dropFirst()
            .debounce(for: .seconds(1), scheduler: DispatchQueue.main)
            .receive(on: DispatchQueue.global(qos: .userInitiated))
            .sink { [weak self] in
                self?.requestProduct(withUpc: $0)
            }
            .store(in: &subscriptions)
//            .compactMap { [weak self] upc in
//                debugPrint("🟢CODE: \(upc)")
//                guard let self = self else {
//                    return Fail(outputType: ProductResponse.self, failure: NetworkingService.NetworkingError.noResponse as Error)
//                        .receive(on: DispatchQueue.main)
//                        .eraseToAnyPublisher()
//                }
//                
//                if let alreadyAdded = self.shoppingCart.findItem(byUpc: upc)?.product {
//                    return Just(alreadyAdded)
//                        .setFailureType(to: Error.self)
//                        .eraseToAnyPublisher()
//                }
//                
//                DispatchQueue.main.async {
//                    self.pendingRequests += 1
//                }
//                
//                return UpcProductRequest(upc: upc)
//                    .perform(byService: self.networkingService)
//                    .map {
//                        DispatchQueue.main.async {
//                            self.pendingRequests = max((self.pendingRequests - 1), 0)
//                        }
//                        return $0
//                    }
//                    .eraseToAnyPublisher()
//            }
//            .switchToLatest()
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] completion in
//                if case .failure(_) = completion {
//                    self?.pendingRequests = max(((self?.pendingRequests ?? 0) - 1), 0)
//                    HapticsFeedbackGenerator.genereteFeedback(.error)
//                }
//            } receiveValue: { [weak self] product in
//                self?.shoppingCart.append(product)
//            }
//            .store(in: &subscriptions)
    }
}
