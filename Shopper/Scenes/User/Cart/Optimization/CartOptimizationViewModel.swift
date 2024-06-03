//
//  CartOptimizationViewModel.swift
//  Shopper
//
//  Created by Гіяна Князєва on 21.12.2022.
//

import Foundation
import Combine

final class CartOptimizationViewModel: NetworkingViewModel {
    
    enum OptimisationOption: String, CaseIterable {
        case price
        case calories
        case carb
        case protein
        case fat
        
        var originalName: String {
            switch self {
            case .calories:
                return "caloriesPer100g"
            default:
                return self.rawValue
            }
        }
    }
    
    @Published private(set) var categories: [Category]
    @Published var selectedCategories = [Category]()
    @Published var selectedMax = Set<String>()
    @Published var selectedMin = Set<String>()
    
    @Published var suggestedProducts = [ProductResponse]()

    @Published private(set) var objectives = OptimisationOption.allCases.map { $0.rawValue }
    
    init(networgingService: NetworkingServiceProtocol, categories: [Category]) {
        self.categories = categories
        super.init(networkingService: networgingService)
    }
    
    func optimise() {
        // TODO: - set output limit on backend
        guard networkingState != .waiting, !categories.isEmpty, !selectedMin.isEmpty || !selectedMax.isEmpty else { return }
        
        let maxOptions = selectedMax.map { OptimisationRequest.OptimisationOption(isMax: true, option: OptimisationOption(rawValue: $0)!.originalName) }
        let minOptions = selectedMin.map { OptimisationRequest.OptimisationOption(isMax: false, option: OptimisationOption(rawValue: $0)!.originalName) }
        let body = OptimisationRequest.Body(
            categories: selectedCategories.map { $0.id },
            options: maxOptions + minOptions)
        
        networkingState = .waiting
        OptimisationRequest(body: body)
            .perform(byService: networkingService)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: handleCompletion) { [weak self] products in
                self?.suggestedProducts = products
            }
            .store(in: &subscriptions)
    }
    
}
