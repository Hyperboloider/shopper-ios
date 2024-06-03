//
//  ListFulfilmentViewModel.swift
//  Shopper
//
//  Created by Illia Kniaziev on 16.05.2024.
//

import Combine
import Foundation

final class ListFulfilmentViewModel: ObservableObject {
    enum DisplayState {
        case products, lists, requesting
    }
    
    @Published var state: DisplayState = .products
    
    @Published var canSubmit = false
    @Published var selectedProductsIds: [String] = []
    @Published var selectedListsIds: [String] = []
    
    @Published var shoppingLists: [ShoppingList]
    @Published var cartItems: [ShoppingCartItem]
    
    private let originalCartItems: [ShoppingCartItem]
    private let onSubmit: ([ShoppingCartItem], [ShoppingList]) -> Void
    private var bag = Set<AnyCancellable>()
    
    init(
        shoppingLists: [ShoppingList],
        cartItems: [ShoppingCartItem],
        onSubmit: @escaping ([ShoppingCartItem], [ShoppingList]) -> Void
    ) {
        self.shoppingLists = shoppingLists
        self.cartItems = cartItems
        self.originalCartItems = cartItems
        self.onSubmit = onSubmit
        
        observeSubmission()
    }
    
    func originalCount(forProductId id: String) -> Double {
        originalCartItems
            .first(where: { $0.id == id })?
            .amount ?? 0
    }
    
    func observeSubmission() {
        Publishers.CombineLatest3(
            $selectedProductsIds,
            $selectedListsIds,
            $state
        )
        .sink { [weak self] ids1, ids2, state in
            guard let self else { return }
            canSubmit = switch state {
            case .products:
                !ids1.isEmpty
            case .lists:
                !ids2.isEmpty
            case .requesting:
                false
            }
        }
        .store(in: &bag)
    }
    
    func submit() {
        if state == .products {
            state = .lists
        } else {
            onSubmit(
                selectedProductsIds
                    .compactMap { id in
                        cartItems.first { $0.id == id }
                    },
                selectedListsIds
                    .compactMap { id in
                        shoppingLists.first { $0.id == id }
                    }
            )
            state = .requesting
        }
    }
    
    func back() {
        state = .products
    }
}
