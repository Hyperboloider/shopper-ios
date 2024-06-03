//
//  CreateCategoryRequest.swift
//  Shopper
//
//  Created by Гіяна Князєва on 22.12.2022.
//

import Foundation

final class CreateCategoryRequest: DecodableRequest<CategoryResponse> {
    init(name: String) {
        let endpoint = APIPath.Category.categories
        let headers = ["Content-Type" : "application/json"]
        let body: Body = [
            "name": name
        ]
        
        super.init(endpoint: endpoint, method: .post, headers: headers, body: body, authorizationStrategy: AuthorizedRequestStrategy())
    }
}
