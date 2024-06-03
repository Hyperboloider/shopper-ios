//
//  ProfileRequest.swift
//  Shopper
//
//  Created by Illia Kniaziev on 18.12.2022.
//

import Foundation

final class ProfileRequest: DecodableRequest<UserResponse> {
    init() {
        let endpoint = APIPath.User.profile
        let headers = ["Content-Type" : "application/json"]
        super.init(endpoint: endpoint, method: .get, headers: headers, authorizationStrategy: AuthorizedRequestStrategy())
    }
}
