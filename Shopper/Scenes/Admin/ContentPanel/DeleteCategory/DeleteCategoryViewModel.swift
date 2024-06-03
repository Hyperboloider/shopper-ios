//
//  DeleteCategoryViewModel.swift
//  Shopper
//
//  Created by Гіяна Князєва on 22.12.2022.
//

import Foundation
import RealmSwift

final class DeleteCategoryViewModel: NetworkingViewModel {
    
    @Published var selectedCategories = [Category]()
    @Published private(set) var categories: [Category]
    
    @Published var isCategoryNotExisting = false
    
    init(networkingService: NetworkingServiceProtocol, categories: [Category]) {
        self.categories = categories
        super.init(networkingService: networkingService)
    }
    
    func submit() {
        guard
            networkingState != .waiting,
            let category = selectedCategories.first
        else { return }
        
        networkingState = .waiting
        DeleteCategoryRequest(id: category.id)
            .perform(byService: networkingService)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.handleCompletion(completion)
                switch completion {
                case .finished:
                    let realm = try! Realm()
                    if let realmObject = realm.object(ofType: Category.self, forPrimaryKey: category.id) {
                        realm.writeAsync {
                            realm.delete(realmObject)
                        }
                    }
                case .failure(let error):
                    if let statusCode = self?.getStatusCodeIfPossible(from: completion), statusCode == 422 {
                        self?.isCategoryNotExisting = true
                    }
                }
            } receiveValue: { _ in }
            .store(in: &subscriptions)
    }
    
}
