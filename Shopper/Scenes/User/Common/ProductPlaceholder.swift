//
//  ProductPlaceholder.swift
//  Shopper
//
//  Created by Гіяна Князєва on 21.12.2022.
//

import SwiftUI

struct ProductPlaceholder: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("placeholder-text-placeholder-text")
                .font(.headline)
            
            Text("placeholder-text-placeholder")
                .font(.subheadline)
        }
        .frame(height: 100)
        .redacted(reason: .placeholder)
    }
}

struct ProductPlaceholder_Previews: PreviewProvider {
    static var previews: some View {
        ProductPlaceholder()
    }
}
