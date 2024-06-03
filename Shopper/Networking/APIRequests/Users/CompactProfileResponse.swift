//
//  CompactProfileResponse.swift
//  Shopper
//
//  Created by Illia Kniaziev on 12.05.2024.
//

import Foundation

final class CompactProfileResponse: DecodableRequest<[CompactUserResponse]> {
    
    init(body: Body) {
        let endpoint = APIPath.User.compactProfiles
        let headers = ["Content-Type" : "application/json"]
        let body = try? JSONEncoder().encode(body)
        super.init(endpoint: endpoint, method: .post, headers: headers, body: body, authorizationStrategy: AuthorizedRequestStrategy())
    }
    
}

extension CompactProfileResponse {
    
    typealias Body = [String]
    
}

