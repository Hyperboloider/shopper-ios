//
//  ApplePayStyle.swift
//  Shopper
//
//  Created by Гіяна Князєва on 20.12.2022.
//

import SwiftUI
import PassKit

struct ApplePayButton: UIViewRepresentable {
    func updateUIView(_ uiView: PKPaymentButton, context: Context) {
        
    }
    func makeUIView(context: Context) -> PKPaymentButton {
        return PKPaymentButton(paymentButtonType: .plain, paymentButtonStyle: .black)
    }
}

struct ApplePayButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        return ApplePayButton()
    }
}
