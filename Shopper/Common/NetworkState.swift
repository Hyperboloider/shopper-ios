//
//  AuthState.swift
//  Shopper
//
//  Created by Illia Kniaziev on 18.12.2022.
//

import Foundation

enum NetworkState: Equatable {
    static func == (lhs: NetworkState, rhs: NetworkState) -> Bool {
        if case .waiting = lhs, case .waiting = rhs {
            return true
        }
        
        if case .success = lhs, case .success = rhs {
            return true
        }
        
        if case .none = lhs, case .none = rhs {
            return true
        }
        
        if case .failure = lhs, case .failure = rhs {
            return true
        }
        
        return false
    }
    
    case none
    case waiting
    case success
    case failure(Error)
}
