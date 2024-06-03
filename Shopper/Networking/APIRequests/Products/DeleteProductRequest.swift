//
//  DeleteProductRequest.swift
//  Shopper
//
//  Created by Гіяна Князєва on 22.12.2022.
//

import Foundation

final class DeleteProductRequest: PlainRequest {
    init(upc: String) {
        let endpoint = APIPath.Product.deleteProduct(withUpc: upc)
        super.init(endpoint: endpoint, method: .delete, authorizationStrategy: AuthorizedRequestStrategy())
    }
}
