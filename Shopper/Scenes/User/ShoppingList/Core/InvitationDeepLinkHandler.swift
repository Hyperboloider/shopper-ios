//
//  InvitationDeepLinkHandler.swift
//  Shopper
//
//  Created by Illia Kniaziev on 07.05.2024.
//

import Foundation

final class InvitationDeepLinkHandler: ObservableObject {
    
    enum OpeningResult: Equatable {
        case none
        case success(id: String)
        case failure(message: String)
    }
    
    @Published var openingResult: OpeningResult = .none
    
    func handleUrl(_ url: URL) {
        guard url.scheme == "shopper", url.host == "accept-invitation" else {
            openingResult = .failure(message: "Invalid URL: URL does not match the expected scheme and host.")
            return
        }
        
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let queryItems = components.queryItems else {
            openingResult = .failure(message: "Invalid URL: Cannot extract query items.")
            return
        }
        
        if let id = queryItems.first(where: { $0.name == "id" })?.value {
            openingResult = .success(id: id)
        } else {
            openingResult = .failure(message: "Invalid URL: ID parameter is missing.")
        }
    }
    
}
