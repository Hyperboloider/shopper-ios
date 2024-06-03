//
//  RefreshRequest.swift
//  Shopper
//
//  Created by Illia Kniaziev on 11.12.2022.
//

import Foundation

final class RefreshRequest: DecodableRequest<AuthResponse> {
    init() {
        let endpoint = APIPath.Auth.refresh
        super.init(
            endpoint: endpoint,
            method: .post,
            authorizationStrategy: RefreshRequestStrategy()
        )
    }
}
