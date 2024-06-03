//
//  SubmitButton.swift
//  Shopper
//
//  Created by Гіяна Князєва on 30.12.2022.
//

import SwiftUI

struct SubmitButton: View {
    
    @Binding var networkingState: NetworkState
    @Binding var canSubmit: Bool
    let title: String
    let onTap: () -> Void
    
    var body: some View {
        Button {
            withAnimation {
                onTap()
            }
        } label: {
            HStack {
                Text(title)
                    .font(.system(.title3, weight: .semibold))
                    .foregroundColor(.white)
                
                if case .waiting = networkingState {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .padding(.leading, 3)
                }
            }
            .frame(minWidth: 100, maxWidth: 260, minHeight: 42, maxHeight: 42, alignment: .center)
            .background(canSubmit ? Color.green : Color.gray)
            .cornerRadius(21)
        }
    }
}
