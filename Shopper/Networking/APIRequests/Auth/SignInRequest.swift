//
//  SignInRequest.swift
//  Shopper
//
//  Created by Illia Kniaziev on 03.12.2022.
//

import Foundation

final class SignInRequest: DecodableRequest<AuthResponse> {
    init(email: Email, password: Password) {
        let endpoint = APIPath.Auth.signin
        let headers = ["Content-Type" : "application/json"]
        let parameters = [
            "email": email.email,
            "password": password.password,
        ]
        super.init(endpoint: endpoint, method: .post, headers: headers, body: parameters, authorizationStrategy: UnauthorizedRequestStrategy())
    }
}
