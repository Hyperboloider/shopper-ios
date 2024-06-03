//
//  CompactProductPreviewView.swift
//  Shopper
//
//  Created by Гіяна Князєва on 24.12.2022.
//

import SwiftUI

struct CompactProductPreviewView: View {
    
    var item: DetailedOrderItemResponse
    
    var body: some View {
        HStack {
            if let imageUrlString = item.product.imageUrl, let imageUrl = URL(string: imageUrlString) {
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
                Text(item.product.name)
                if item.product.isPricePerKilo {
                    Text("\(String(format: "%.2f", item.quantity)) kilo")
                } else {
                    Text("\(Int(item.quantity)) \(item.quantity == 1 ? "item" : "items")")
                }
            }
        }
    }
}

struct CompactProductPreviewView_Previews: PreviewProvider {
    
    static var previews: some View {
        CompactProductPreviewView(item: DetailedOrderItemResponse(quantity: 10, product: ProductResponse(
            id: "jknfwelkf",
            name: "Coca-Cola Zero",
            description: "Sugar-free Coke.",
            upc: "123445312345",
            pricePerKilo: 15.10, weightPerItem: 1,
            isPricePerKilo: false,
            caloriesPer100g: 0,
            protein: 0,
            fat: 0,
            carb: 0,
            category: "fuzzy drinks", imageUrl: "")))
            .previewLayout(.fixed(width: 350, height: 150))
            .buttonStyle(PlainButtonStyle())
    }
}
