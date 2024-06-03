//
//  Category.swift
//  Shopper
//
//  Created by Гіяна Князєва on 21.12.2022.
//

import Foundation
import RealmSwift

final class Category: Object, ObjectKeyIdentifiable {
    
    @Persisted(primaryKey: true) var id: String
    
    convenience init(response: CategoryResponse) {
        self.init()
        self.id = response.id
    }
    
}

extension Category: Taggable {
    var displayName: String { id }
}
