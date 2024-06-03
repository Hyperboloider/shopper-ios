//
//  SearchViewModel.swift
//  Shopper
//
//  Created by Гіяна Князєва on 22.12.2022.
//

import Foundation
import Combine

class SearchViewModel: NetworkingViewModel {
    
    @Published var searchQuery = ""
    @Published var searchResults = [ProductResponse]()
    
    func subscribeOnSearch() {
        $searchQuery
            .removeDuplicates()
            .debounce(for: .seconds(0.25), scheduler: DispatchQueue.main)
            .receive(on: DispatchQueue.global(qos: .userInitiated))
            .map { [weak self] query in
                guard let self = self else {
                    return Just([ProductResponse]())
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
                
                if query.isEmpty || query.count < 3 {
                    
                    DispatchQueue.main.async {
                        self.searchResults.removeAll()
                    }
                    
                    return Just([ProductResponse]())
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
                
                return SearchCompletionRequest(query: query)
                    .perform(byService: self.networkingService)
                    .eraseToAnyPublisher()
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }) { [weak self] results in
                self?.searchResults = results
            }
            .store(in: &subscriptions)
    }
    
}
