//
//  InputView.swift
//  Shopper
//
//  Created by Гіяна Князєва on 21.12.2022.
//

import SwiftUI

struct InputField<FocusEnum: Hashable>: View {
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
            
            TextField(placeholder, text: $text)
                .font(.system(.title3))
                .focused($focusState, equals: focus)
                .onSubmit {
                    onSubmit()
                }
        }
    }
}
