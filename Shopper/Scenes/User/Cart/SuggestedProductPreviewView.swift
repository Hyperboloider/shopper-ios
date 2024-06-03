//
//  SuggestedProductPreviewView.swift
//  Shopper
//
//  Created by Гіяна Князєва on 29.12.2022.
//

import SwiftUI

struct SuggestedProductPreviewView: View {
    
    var product: ProductResponse
    
    var body: some View {
        HStack {
            if let imageUrlString = product.imageUrl, let imageUrl = URL(string: imageUrlString) {
                AsyncImage(
                    url: imageUrl,
                    content: { image in
                        image.resizable()
                             .aspectRatio(contentMode: .fit)
                             .frame(maxWidth: 30, maxHeight: 30)
                    },
                    placeholder: {
                        ProgressView()
                    }
                )
            } else {
                Image(systemName: "bag.badge.questionmark")
                    .scaleEffect(x: 1.5, y: 1.5)
                    .aspectRatio(1, contentMode: .fit)
                    .foregroundColor(.secondary)
                    .frame(width: 30, height:30)
            }
            
            VStack(alignment: .leading) {
                Text(product.name)
                    .font(.system(.title3))
                
                UAHView(total: product.price)
                    .font(.system(.body, weight: .semibold))
            }
        }
    }
}
