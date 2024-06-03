//
//  User.swift
//  Shopper
//
//  Created by Гіяна Князєва on 20.12.2022.
//

import Foundation
import RealmSwift

final class User: Object, ObjectKeyIdentifiable {
    
    fileprivate static let uniqueKey = "USER"
    
    enum Role: String, PersistableEnum {
        case user = "USER"
        case admin = "ADMIN"
        
        static func fromUserRole(_ role: UserResponse.Role) -> Role {
            return Role(rawValue: role.rawValue)!
        }
    }
    
    @Persisted(primaryKey: true) var key = User.uniqueKey
    @Persisted var id: String
    @Persisted var firstName: String
    @Persisted var lastName: String
    @Persisted var email: String
    @Persisted var roles: List<Role>
    
    var isAdmin: Bool { roles.contains(.admin) }
    
    convenience init(response: UserResponse) {
        self.init()
        self.id = response.id
        self.firstName = response.firstName
        self.lastName = response.lastName
        self.email = response.email
        self.roles = response.roles.reduce(into: List<Role>()) { $0.append(Role.fromUserRole($1)) }
    }
    
}

// MARK: - Serialization
extension User {
    
    static var userId: String {
        restore()?.id ?? "-1"
    }
    private static let queue = DispatchQueue(label: "user-serialization-queue", qos: .userInitiated)
    
    static func save(_ response: UserResponse) {
        queue.sync {
            let realm = try! Realm(queue: queue)
            try! realm.write {
                realm.add(User(response: response), update: .all)
            }
        }
    }
    
    static func restore() -> User? {
        return queue.sync {
            let realm = try! Realm()
            return realm.object(ofType: User.self, forPrimaryKey: User.uniqueKey)
        }
    }
    
}
