//
//  String+Extension.swift
//  Shopper
//
//  Created by Гіяна Князєва on 21.12.2022.
//

import Foundation

extension String {
    var isNonNegDouble: Bool {
        if let double = Double(self.replacingOccurrences(of: ",", with: ".")), double >= 0 {
            return true
        }
        
        return false
    }
    
    var isPositiveInt: Bool {
        if let int = Int(self), int > 0 {
            return true
        }
        
        return false
    }
}
