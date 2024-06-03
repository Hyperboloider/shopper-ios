//
//  AddProductViewModel.swift
//  Shopper
//
//  Created by Гіяна Князєва on 21.12.2022.
//

import Foundation
import Combine
import _PhotosUI_SwiftUI

final class AddProductViewModel: NetworkingViewModel {
    
    @Published var name = ""
    @Published var description = ""
    @Published var upc = ""
    @Published var price = ""
    @Published var weightPerItem = ""
    @Published var isPricePerKilo = false
    @Published var calories = ""
    @Published var protein = ""
    @Published var fat = ""
    @Published var carb = ""
    
    @Published var imageData: Data?
    
    @Published var selectedCategories = [Category]()
    @Published private(set) var categories: [Category]
    
    @Published var isUpcDuplicate = false
    @Published private(set) var canSubmit = false
    
    init(networkingService: NetworkingServiceProtocol, categories: [Category]) {
        self.categories = categories
        super.init(networkingService: networkingService)
        subscribeOnInput()
    }
    
    func submit() {
        guard
            networkingState != .waiting,
            let price = Double(price),
            let intWeight = Int(weightPerItem),
            let calories = Double(calories),
            let protein = Double(protein),
            let fat = Double(fat),
            let carb = Double(carb),
            let category = selectedCategories.first
        else { return }
        
        let weight = Double(intWeight)
        let pricePerKilo = price / (weight / 1000)
        
        let body = CreateProductRequest.Body(
            name: name,
            description: description,
            upc: upc,
            price: pricePerKilo,
            isPricePerKilo: isPricePerKilo,
            weightPerItem: weight,
            caloriesPer100g: calories,
            protein: protein,
            fat: fat,
            carb: carb,
            categoryId: category.id,
            imageData: imageData
        )
        
        networkingState = .waiting
        if let request = CreateProductRequest(body: body) {
            request
                .perform(byService: networkingService)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] completion in
                    self?.handleCompletion(completion)
                    if case .failure(let error) = completion {
                        if let statusCode = self?.getStatusCodeIfPossible(from: completion), statusCode == 422 {
                            self?.networkingState = .failure(error)
                            self?.isUpcDuplicate = true
                        }
                    }
                } receiveValue: { _ in }
                    .store(in: &subscriptions)
        }
    }
}

// MARK: - Validation
private extension AddProductViewModel {
    func subscribeOnInput() {
        Publishers
            .CombineLatest4(
                Publishers.CombineLatest4($name, $description, $upc, $price),
                Publishers.CombineLatest4($calories, $protein, $fat, $carb),
                Publishers.CombineLatest($weightPerItem, $isPricePerKilo),
                $selectedCategories)
            .sink { [weak self] general, nutritions, weight, category in
                let (name, description, upc, price) = general
                let (calories, protein, fat, carb) = nutritions
                let (weight, isPricePerKilo) = weight
                
                if weight != "1000", isPricePerKilo {
                    self?.weightPerItem = "1000"
                }
                
                guard
                    [name, description, upc].allSatisfy({ !$0.isEmpty }),
                    [price, calories, protein, fat, carb].allSatisfy({ $0.isNonNegDouble }),
                    weight.isPositiveInt,
                    !category.isEmpty
                else {
                    self?.canSubmit = false
                    return
                }
                
                self?.canSubmit = true
            }
            .store(in: &subscriptions)
    }
}
