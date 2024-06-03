//
//  SecureInputField.swift
//  Shopper
//
//  Created by Гіяна Князєва on 21.12.2022.
//

import SwiftUI

struct SecureInputField<FocusEnum: Hashable>: View {
    @FocusState var focusState: FocusEnum?
    @Binding var text: String

    let title: String
    let placeholder: String
    let focus: FocusEnum
    let onSubmit: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.system(.title3, weight: .semibold))
            
            SecureField(placeholder, text: $text)
                .font(.system(.title3))
                .frame(minHeight: 42)
                .padding(.leading, 20)
                .background {
                    Color.gray.opacity(0.2)
                }
                .cornerRadius(21)
                .overlay {
                    if focusState == focus {
                        RoundedRectangle(cornerRadius: 21)
                            .stroke(.green, lineWidth: 1)
                    }
                }
                .focused($focusState, equals: focus)
                .onSubmit {
                    onSubmit()
                }
        }
    }
}
