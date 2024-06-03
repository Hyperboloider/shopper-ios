//
//  ShopperApp.swift
//  Shopper
//
//  Created by Illia Kniaziev on 18.12.2022.
//

import SwiftUI

@main
struct ShopperApp: App {
    @StateObject private var appState: AppState
    @StateObject private var permissionManager = PermissonManager()
    @StateObject private var deepLinkHandler = InvitationDeepLinkHandler()
    @StateObject private var shoppingListModel: ShoppingListModel
    private let networkingService: NetworkingService
    
    init() {
        let appState = AppState()
        let networkingService = NetworkingService()
        self.networkingService = networkingService
        self._appState = StateObject(wrappedValue: appState)
        self._shoppingListModel = StateObject(wrappedValue: ShoppingListModel(
            networkingService: networkingService,
            isUserSignedInPublisher: appState.$isUserAuthorized.eraseToAnyPublisher())
        )
    }
    
    @State var isShowingError = false
    
    var body: some Scene {
        WindowGroup {
//            VStack {
//                if appState.isUserAuthorized {
//                    if appState.isAdmin {
//                        AdminMenuView()
//                            .onAppear {
//                                ApplicationSetup.loadContent(using: networkingService)
//                            }
//                    } else {
//                        MenuView(shoppingCart: ShoppingCart(cartRestorationService: CartRestorationService(networkingService: networkingService)))
//                            .onAppear {
//                                ApplicationSetup.loadContent(using: networkingService)
//                            }
//                    }
//                } else {
//                    NavigationView {
//                        AuthView()
//                    }
//                }
//            }
            AdminMenuView()
            .onAppear {
                ApplicationSetup.loadContent(using: networkingService)
            }
            .onOpenURL { url in
                deepLinkHandler.handleUrl(url)
            }
            .alert("Failed to open invitation", isPresented: $isShowingError, actions: {
                Button("OK", role: .cancel) {}
            }, message: {
                if case .failure(let message) = deepLinkHandler.openingResult {
                    Text(message)
                } else if !shoppingListModel.invitationErrorMessage.isEmpty {
                    Text(shoppingListModel.invitationErrorMessage)
                }
            })
            .onReceive(shoppingListModel.$invitationErrorMessage.dropFirst()) { value in
                isShowingError = true
            }
            .onReceive(deepLinkHandler.$openingResult) { value in
                switch value {
                case .failure(_):
                    isShowingError = true
                case .success(let id):
                    shoppingListModel.acceptInvitation(id: id)
                case .none:
                    break
                }
            }
            .animation(.linear, value: appState.isUserAuthorized)
            .animation(.linear, value: appState.isAdmin)
            .environmentObject(appState)
            .environmentObject(networkingService)
            .environmentObject(permissionManager)
            .environmentObject(shoppingListModel)
        }
    }
}
