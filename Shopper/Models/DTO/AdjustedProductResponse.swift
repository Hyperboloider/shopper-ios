//
//  AdjustedProductResponse.swift
//  Shopper
//
//  Created by Гіяна Князєва on 01.01.2023.
//

import Foundation

struct AdjustedProductResponse: Decodable {
    let quantity: Double
    let product: ProductResponse
}
