//
//  UserManagementViewModel.swift
//  Shopper
//
//  Created by Illia Kniaziev on 12.05.2024.
//

import Foundation
import Combine
import RealmSwift

final class UserManagementViewModel: NetworkingViewModel {
    
    @Published var users: [CompactUserResponse] = []
    private let listId: String
    private let userIds: [String]
    
    init(
        networkingService: NetworkingServiceProtocol,
        listId: String,
        userIds: [String]
    ) {
        self.listId = listId
        self.userIds = userIds
        super.init(networkingService: networkingService)
    }
    
    func fetchUsers() {
        let user = User.restore()
        networkingState = .waiting
        CompactProfileResponse(body: userIds)
            .perform(byService: networkingService)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: handleCompletion) { [weak self] in
                self?.users = $0.filter { $0.id != user?.id }
            }
            .store(in: &subscriptions)
    }
    
    func handleRemoval(indexSet: IndexSet) {
        let ids = indexSet.map { users[$0].id }
        let requests = ids.map {
            KickUserRequest(listId: listId, userId: $0)
                .perform(byService: networkingService)
        }
        Publishers
            .MergeMany(requests)
            .collect()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: handleCompletion) { [weak self] _ in
                self?.filterUsers(fromIds: ids)
                self?.networkingState = .success
            }
            .store(in: &subscriptions)
    }
    
    private func filterUsers(fromIds ids: [String]) {
        let lookup = Set(ids)
        users = users.filter { !lookup.contains($0.id) }
        
        let realm = try! Realm()
        try! realm.write {
            if let shoppingList = realm.object(ofType: ShoppingList.self, forPrimaryKey: listId) {
                let users = Array(shoppingList.users)
                shoppingList.users.removeAll()
                shoppingList.users.append(objectsIn: users.filter { !lookup.contains($0) })
            }
            ShoppingListModel.shoppingListRedrawSubject.send()
        }
    }
    
}
