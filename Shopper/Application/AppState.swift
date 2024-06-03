//
//  AppState.swift
//  Shopper
//
//  Created by Illia Kniaziev on 18.12.2022.
//

import Foundation
import Combine
import RealmSwift

final class AppState: ObservableObject {
    
    @Published var isUserAuthorized = false
    @Published var isAdmin = false {
        didSet {
            UserDefaults.standard.set(isAdmin, forKey: "IsAdmin")
        }
    }
    
    init() {
//        JWTHelper.removeToken()
        debugPrint("🔴🔴🔴🔴🔴🔴🔴🔴🔴OOOOOOOOOOOOOOOO")
        isUserAuthorized = !JWTHelper.userNeedsAuthorization && User.restore() != nil
        isAdmin = UserDefaults.standard.bool(forKey: "IsAdmin")
        
        NotificationCenter.default.addObserver(self, selector: #selector(logOut), name: .logOutNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func logOut() {
        DispatchQueue.main.async {
            self.isUserAuthorized = false
            JWTHelper.removeToken()
            UserDefaults.standard.removeObject(forKey: "IsAdmin")
            
            let realm = try! Realm()
            try! realm.write {
                realm.deleteAll()
            }
        }
    }
    
}
