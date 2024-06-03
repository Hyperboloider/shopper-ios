//
//  SignUpRequest.swift
//  Shopper
//
//  Created by Illia Kniaziev on 09.12.2022.
//

import Foundation

final class SignUpRequest: DecodableRequest<AuthResponse> {
    init(
        firstName: String,
        lastName: String,
        email: Email,
        password: Password
    ) {
        let endpoint = APIPath.Auth.signup
        let headers = ["Content-Type" : "application/json"]
        let parameters = [
            "firstName": firstName,
            "lastName": lastName,
            "email": email.email,
            "password": password.password,
        ]
        
        super.init(endpoint: endpoint, method: .post, headers: headers, body: parameters, authorizationStrategy: UnauthorizedRequestStrategy())
    }
}
