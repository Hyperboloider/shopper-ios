//
//  Email.swift
//  Shopper
//
//  Created by Illia Kniaziev on 18.12.2022.
//

import Foundation

struct Email {
    let email: String
    
    init?(email: String) {
        guard Validator.validate(string: email, usingPattern: .email) else { return nil }
        self.email = email
    }
}
