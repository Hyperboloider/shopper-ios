//
//  CategoriesRequest.swift
//  Shopper
//
//  Created by Гіяна Князєва on 21.12.2022.
//

import Foundation

final class CategoriesRequest: DecodableRequest<[CategoryResponse]> {
    init() {
        let endpoint = APIPath.Category.categories
        super.init(endpoint: endpoint, method: .get, authorizationStrategy: AuthorizedRequestStrategy())
    }
}
