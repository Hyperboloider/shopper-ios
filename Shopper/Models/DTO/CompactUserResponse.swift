//
//  CompactUserResponse.swift
//  Shopper
//
//  Created by Illia Kniaziev on 12.05.2024.
//

import Foundation

struct CompactUserResponse: Decodable, Identifiable {
    let id: String
    let fullName: String
}
