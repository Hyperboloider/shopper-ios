//
//  AddCategoryViewModel.swift
//  Shopper
//
//  Created by Гіяна Князєва on 22.12.2022.
//

import Foundation
import RealmSwift

final class AddCategoryViewModel: NetworkingViewModel {
    
    @Published var name = ""
    @Published var isCategoryDiplicate = false
    
    func submit() {
        guard networkingState != .waiting, !name.isEmpty else { return }
        
        networkingState = .waiting
        CreateCategoryRequest(name: name)
            .perform(byService: networkingService)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if let statusCode = self?.getStatusCodeIfPossible(from: completion), statusCode == 422 {
                    self?.name = ""
                    self?.isCategoryDiplicate = true
                }
                self?.handleCompletion(completion)
            } receiveValue: { response in
                let realm = try! Realm()
                realm.writeAsync({
                    realm.add(Category(response: response), update: .all)
                })
            }
            .store(in: &subscriptions)

    }
    
}
