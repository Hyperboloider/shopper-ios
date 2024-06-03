//
//  ShoppingListModel.swift
//  Shopper
//
//  Created by Illia Kniaziev on 07.05.2024.
//

import Foundation
import Combine
import RealmSwift
import SocketIO

final class ShoppingListModel: NetworkingViewModel {
    
    static let shoppingListRedrawSubject = PassthroughSubject<Void, Never>()
    
    private let realm = try! Realm()
    private let eventsObserver = ServerEventsObserver()
    @Published private(set) var invitationErrorMessage = ""
    @ObservedResults(ShoppingList.self, filter: NSPredicate(format: "creatorId == %@", User.userId)) var ownShoppingLists
    @ObservedResults(ShoppingList.self, filter: NSPredicate(format: "creatorId != %@", User.userId)) var otherShoppingLists
    
    init(
        networkingService: any NetworkingServiceProtocol,
        isUserSignedInPublisher: AnyPublisher<Bool, Never>
    ) {
        super.init(networkingService: networkingService)
        observeUserStatus(isUserSignedInPublisher)
        setupObservers()
        
        ShoppingListModel.shoppingListRedrawSubject
            .sink(receiveValue: triggerChange)
            .store(in: &subscriptions)
    }
    
    // MARK: - WebSocket
    func handleSocketConnection() {
        guard let user = User.restore(), let socketId = eventsObserver.socketId else { return print("🔴FAILED TO SUBSCRIBE") }
        print("🔵", socketId)
        eventsObserver.sendEvent(
            forName: ClientToServerEventType.join.rawValue,
            event: JoinShoppingListSchema(
                eventName: .join,
                user: UserSchema(
                    userId: user.id,
                    userName: user.firstName,
                    socketId: socketId
                )
            )
        )
    }
    
    func handleSocketChange(change: UpdateListSchema) {
        // monitor internet connection and refetch lists when established
        guard
            let user = User.restore(),
            user.id != change.senderId
        else { return }
        fetchLists()
    }
    
    private func setupObservers() {
        eventsObserver.setHandler(EventHandler<String>(name: SocketClientEvent.connect.rawValue) { [weak self] _ in
            self?.handleSocketConnection()
        })
        eventsObserver.setHandler(EventHandler(name: ServerToClientEventType.update.rawValue) { [weak self] in
            self?.handleSocketChange(change: $0)
        })
    }
    
    private func triggerChange() {
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
    }
    
    // MARK: - Persistance
    func acceptLists(_ lists: [ShoppingList]) {
        try? realm.write {
            lists.forEach { realm.add($0) }
            self.triggerChange()
        }
    }
    
    private func clearDataSource() {
        try? realm.write {
            let existingLists = realm.objects(ShoppingList.self)
            realm.delete(existingLists)
            self.triggerChange()
        }
    }
    
    private func removeLists(ids: [String]) {
        let lookup = Set(ids)
        
        try? realm.write {
            let existingLists = realm
                .objects(ShoppingList.self)
                .filter { lookup.contains($0.id) }
            realm.delete(existingLists)
            triggerChange()
        }
    }
    
    func restoreLists() {
        let existingLists = realm.objects(ShoppingList.self)
        acceptLists(Array(existingLists))
    }
    
    // MARK: - Networking
    func deleteOwn(ids: [String]) {
        deleteLists(withId: ids)
    }
    
    func deleteOther(ids: [String]) {
        deleteLists(withId: ids)
    }
    
    func updateOrCreateShoppingLists(from responses: [ShoppingListResponse]) {
        try! realm.write {
            // Delete lists not present in responses
            let existingListIds = Set(realm.objects(ShoppingList.self).map { $0.id })
            let newResponseIds = Set(responses.map { $0.id })
            let listsToDelete = existingListIds.subtracting(newResponseIds)
            let listsToDeleteResults = realm.objects(ShoppingList.self).filter("id IN %@", listsToDelete)
            realm.delete(listsToDeleteResults)
            
            // Update or create lists from responses
            for response in responses {
                if let existingShoppingList = realm.object(ofType: ShoppingList.self, forPrimaryKey: response.id) {
                    existingShoppingList.update(with: response)
                } else {
                    let newShoppingList = ShoppingList(response: response)
                    realm.add(newShoppingList)
                }
            }
            triggerChange()
        }
    }
    
    func fetchLists() {
        networkingState = .waiting
        GetShoppingListsRequest()
            .perform(byService: networkingService)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }) { [weak self] lists in
                debugPrint("🔵", lists)
//                self?.clearDataSource()
                self?.updateOrCreateShoppingLists(from: lists)
                self?.networkingState = .success
            }
            .store(in: &subscriptions)
    }
    
    func createList(newListName: String) {
        guard !newListName.isEmpty else { return }
        networkingState = .waiting
        CreateShoppingListRequest(body: .init(name: newListName, products: []))
            .perform(byService: networkingService)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: handleCompletion) { [weak self] in
                self?.acceptLists([ShoppingList(response: $0)])
            }
            .store(in: &subscriptions)
    }
    
    func acceptInvitation(id: String) {
        AcceptShoppingListInvitationRequest(invitationId: id)
            .perform(byService: networkingService)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.invitationErrorMessage = "\((error as? NetworkingService.NetworkingError)?.localizedDescription ?? "None")"
                }
            } receiveValue: { [weak self] in
                self?.acceptLists([ShoppingList(response: $0)])
            }
            .store(in: &subscriptions)
    }
    
    func fulfilLists(products: [ShoppingCartItem], lists: [ShoppingList], completion: @escaping () -> Void) {
        FulfilShoppingListRequest(
            body: .init(
                listsIds: lists.map(\.id),
                products: products.map {
                    FulfilShoppingListRequest.FulfilShoppingListItem(quantity: $0.amount, product: $0.id)
                }
            )
        )
        .perform(byService: networkingService)
        .receive(on: DispatchQueue.main)
        .handleEvents(receiveCompletion: { _ in
            completion()
        })
        .sink(receiveCompletion: handleCompletion, receiveValue: { _ in })
        .store(in: &subscriptions)
    }
    
    private func deleteLists(withId ids: [String]) {
        let requests = ids.map { DeleteShoppingListRequest(id: $0).perform(byService: networkingService) }
        Publishers
            .MergeMany(requests)
            .collect()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: handleCompletion) { [weak self] _ in
                self?.removeLists(ids: ids)
                self?.networkingState = .success
            }
            .store(in: &subscriptions)
    }
    
    // MARK: - Observation
    private func observeUserStatus(_ publisher: AnyPublisher<Bool, Never>) {
        publisher
            .sink { [weak self] isSignedIn in
                guard let self else { return }
                if isSignedIn {
                    eventsObserver.connect()
                    restoreLists()
                    fetchLists()
                } else {
                    clearDataSource()
                }
            }
            .store(in: &subscriptions)
    }
    
}
