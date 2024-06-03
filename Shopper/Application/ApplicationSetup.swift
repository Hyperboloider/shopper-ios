//
//  ApplicationSetup.swift
//  Shopper
//
//  Created by Гіяна Князєва on 21.12.2022.
//

import Foundation
import Combine
import RealmSwift

final class ApplicationSetup {
    
    private init() {}
    
    private static var subscriptions = Set<AnyCancellable>()
    
    private static let storageQueue = DispatchQueue(label: "application-setup", qos: .background)
    
    static func loadContent(using service: NetworkingServiceProtocol) {
        CategoriesRequest()
            .perform(byService: service)
            .receive(on: storageQueue)
            .sink { _ in } receiveValue: { response in
                let realm = try! Realm(queue: storageQueue)
                let objects = response.map(Category.init)
                try! realm.write {
                    objects.forEach { realm.add($0, update: .all) }
                }
            }
            .store(in: &subscriptions)
    }
    
}
