//
//  Validator.swift
//  Shopper
//
//  Created by Illia Kniaziev on 18.12.2022.
//

import Foundation

final class Validator {
    
    enum ValidatoionPattern: String {
        
        case email = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        case password = "^.{8,}$"
    }
    
    static func validate(string: String, usingPattern pattern: ValidatoionPattern) -> Bool {
        return string.range(of: pattern.rawValue, options: .regularExpression, range: nil, locale: nil) != nil
    }
    
}
