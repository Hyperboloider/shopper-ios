//
//  MenuView.swift
//  Shopper
//
//  Created by Illia Kniaziev on 19.12.2022.
//

import SwiftUI
import RealmSwift

struct MenuView: View {
    @StateObject private var shoppingCart: ShoppingCart
    @EnvironmentObject private var networkingService: NetworkingService
    @ObservedResults(User.self) var users
    
    init(shoppingCart: ShoppingCart) {
        self._shoppingCart = StateObject(wrappedValue: shoppingCart)
    }
    
    var body: some View {
        TabView {
            CartView(viewModel: CartViewModel(networkingService: networkingService))
                .tabItem {
                    Label("Cart", systemImage: "cart.fill")
                }
            
            ScannerView(viewModel: ScannerViewModel(networkingService: networkingService, shoppingCart: shoppingCart))
                .tabItem {
                    Label("Scanner", systemImage: "barcode.viewfinder")
                }
            
            if let user = users.first {
                if !user.isAdmin {
                    ShoppingListsView()
                        .tabItem {
                            Label("Lists", systemImage: "checklist")
                        }
                }
                
                ProfileView(user: user)
                    .tabItem {
                        Label("Profile", systemImage: "person.crop.circle")
                    }
            }
        }
        .environmentObject(shoppingCart)
    }
}
