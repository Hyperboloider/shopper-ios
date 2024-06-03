//
//  SearchCompletionRequest.swift
//  Shopper
//
//  Created by Гіяна Князєва on 28.12.2022.
//

import Foundation

final class SearchCompletionRequest: DecodableRequest<[ProductResponse]> {
    
    init(query: String) {
        let endpoint = APIPath.Search.autocomplete
        let queryItem = URLQueryItem(name: "query", value: query)
        super.init(endpoint: endpoint, method: .get, queryItems: [queryItem], authorizationStrategy: AuthorizedRequestStrategy())
    }
    
}
