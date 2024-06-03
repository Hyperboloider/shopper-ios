//
//  View + Extension.swift
//  Shopper
//
//  Created by Гіяна Князєва on 31.12.2022.
//

import SwiftUI

extension View {
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
