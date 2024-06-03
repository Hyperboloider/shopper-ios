//
//  Password.swift
//  Shopper
//
//  Created by Illia Kniaziev on 18.12.2022.
//

import Foundation

struct Password {
    let password: String
    
    init?(password: String) {
        guard Validator.validate(string: password, usingPattern: .password) else { return nil }
        self.password = password
    }
}
