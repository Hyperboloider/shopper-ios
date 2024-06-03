//
//  UpcProductRequest.swift
//  Shopper
//
//  Created by Illia Kniaziev on 19.12.2022.
//

import Foundation

final class UpcProductRequest: DecodableRequest<ProductResponse> {
    init(upc: String) {
        let endpoint = APIPath.Product.getProduct(byUpc: upc)
        let headers = ["Content-Type" : "application/json"]
        super.init(endpoint: endpoint, method: .get, headers: headers, authorizationStrategy: AuthorizedRequestStrategy())
    }
}
