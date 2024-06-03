//
//  NetworkingPath.swift
//  Shopper
//
//  Created by Illia Kniaziev on 03.12.2022.
//

final class APIPath {
    
    private init() {}
    
    //MARK: - endpoint base helpers
    enum Auth {
        
        private static let endpointBase = "auth"
        
        ///used to log a user in, providing user's credentials
        static let signin = APIPath.createPath(endpointBase, "signin")
        
        ///used to register a user, providing user's data and new credentials
        static let signup = APIPath.createPath(endpointBase, "signup")
        
        ///used to refresh `accessToken`, providing `refreshToken` as a Bearer token
        static let refresh = APIPath.createPath(endpointBase, "refresh")
        
        ///used to log a user out, deactivating tokens
        static let logout = APIPath.createPath(endpointBase, "logout")
        
    }
    
    enum User {
        
        private static let endpointBase = "users"
        
        static let profile = APIPath.createPath(endpointBase, "profile")
        
        static let compactProfiles = APIPath.createPath(endpointBase, "compactInfo")
        
    }
    
    enum Product {
        
        private static let endpointBase = "products"
        
        static let products = APIPath.createPath(endpointBase)
        
        static func deleteProduct(withUpc upc: String) -> String {
            APIPath.createPath(endpointBase, "upc", upc)
        }
        
        static func getProduct(byId id: String) -> String {
            APIPath.createPath(endpointBase, "id", id)
        }

        static func getProduct(byUpc upc: String) -> String {
            APIPath.createPath(endpointBase, "upc", upc)
        }
        
    }
    
    enum Category {
        
        private static let endpointBase = "categories"
        
        static let categories = APIPath.createPath(endpointBase)
        
        static func deleteCategory(withId id: String) -> String {
            return APIPath.createPath(endpointBase, "delete", id)
        }
        
    }
    
    enum Order {
        
        private static let endpointBase = "orders"
        
        static let orders = APIPath.createPath(endpointBase)
        
        static func orders(byUserId id: String) -> String {
            return APIPath.createPath(endpointBase, "user", id)
        }
        
        static func orders(byOrderId id: String) -> String {
            return APIPath.createPath(endpointBase, id)
        }
        
    }
    
    enum Search {
        
        private static let endpointBase = "search"
        
        static let autocomplete = APIPath.createPath(endpointBase, "autocomplete")
        
        static let similarCarts = APIPath.createPath(endpointBase, "similarCarts")
        
        static let minimax = APIPath.createPath(endpointBase, "minimax")
        
    }
    
    enum ShoppingList {
        
        private static let endpointBase = "shopping-lists"
        
        static let shoppingLists = APIPath.createPath(endpointBase)
        
        static let fulfilShoppingLists = APIPath.createPath(endpointBase, "fulfill")
        
        static func shoppingList(byId id: String) -> String {
            APIPath.createPath(endpointBase, id)
        }
        
        static func deleteList(withId id: String) -> String {
            APIPath.createPath(endpointBase, id)
        }
        
        static func updateList(withId id: String) -> String {
            APIPath.createPath(endpointBase, id)
        }
        
        static func acceptInvitation(withId id: String) -> String {
            APIPath.createPath(endpointBase, "invitations", id)
        }
        
        static func generateInvitation(withListId listId: String) -> String {
            APIPath.createPath(endpointBase, listId, "invite")
        }
        
        static func kickUser(fromList listId: String, withUserId userId: String) -> String {
            APIPath.createPath(endpointBase, listId, "kick", userId)
        }
        
    }
    
    enum WebSocket {
        
        static let path = baseUrl
        
    }
    
    fileprivate static let baseUrl = "https://0ec6-188-163-53-139.ngrok-free.app" //"http://localhost:3000"
    
    fileprivate static func createPath(_ components: String...) -> String {
        var pathComponents = [baseUrl]
        pathComponents.append(contentsOf: components)
        return pathComponents.joined(separator: "/")
    }
    
}
