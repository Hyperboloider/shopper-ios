//
//  ProductPreviewModel.swift
//  Shopper
//
//  Created by Гіяна Князєва on 31.12.2022.
//

import Foundation

final class ProductPreviewModel: ObservableObject {
    
    @Published var counterStep = 0.0
    @Published var roundingRatio = 1.0
    @Published var minimumValue = 1.0
    @Published var canDelete = true
    
}
