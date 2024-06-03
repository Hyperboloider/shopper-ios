//
//  DeleteCategoryRequest.swift
//  Shopper
//
//  Created by Гіяна Князєва on 22.12.2022.
//

import Foundation

final class DeleteCategoryRequest: PlainRequest {
    init(id: String) {
        let endpoint = APIPath.Category.deleteCategory(withId: id)
        super.init(endpoint: endpoint, method: .delete, authorizationStrategy: AuthorizedRequestStrategy())
    }
}
