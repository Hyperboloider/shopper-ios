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
    @Published var searchResults = [SearchResponse]()
    
    func subscribeOnSearch() {
        $searchQuery
            .removeDuplicates()
            .receive(on: DispatchQueue.global(qos: .userInitiated))
            .debounce(for: .seconds(0.25), scheduler: DispatchQueue.main)
            .compactMap { query in
                if query.isEmpty || query.count < 3 {
                    self.searchResults.removeAll()
                    return Just([SearchResponse]())
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
                
                return Just([
                    SearchResponse(id: "aslkj3u2fkje", name: query),
                    SearchResponse(id: "aslkj3u2fkje", name: query+"1"),
                    SearchResponse(id: "aslkj3u2fkje", name: query+"2")])
                    .setFailureType(to: Error.self)
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
