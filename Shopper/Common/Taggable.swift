//
//  Taggable.swift
//  Shopper
//
//  Created by Гіяна Князєва on 21.12.2022.
//

import Foundation

protocol Taggable: Hashable, Equatable {
    var displayName: String { get }
}

extension String: Taggable {
    var displayName: String { self }
}
