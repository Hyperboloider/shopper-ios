//
//  TagPicker.swift
//  Shopper
//
//  Created by Гіяна Князєва on 21.12.2022.
//

import SwiftUI
import SwiftUIFlow

struct TagPicker: View {
    
    let dataSource: [String]
    @Binding var selection: Set<String>
    @Binding var unavailable: Set<String>
    
    var body: some View {
        VFlow(alignment: .leading) {
            ForEach(Array(dataSource.enumerated()), id: \.offset) { index, item in
                if unavailable.contains(item) {
                    EmptyView()
                } else {
                    Label {
                        Text(item)
                    } icon: {
                        Image(systemName: "xmark.circle.fill")
                            .renderingMode(.template)
                            .foregroundColor(.white)
                            .rotationEffect(selection.contains(item) ? .zero : .degrees(45))
                            .background {
                                (selection.contains(item) ? Color.gray : Color.green)
                                    .cornerRadius(10)
                            }
                    }
                    .padding(.vertical, 5)
                    .padding(.horizontal, 15)
                    .foregroundColor(.white)
                    .background(selection.contains(item) ? Color.green : Color.gray)
                    .cornerRadius(15)
                    .onTapGesture {
                        withAnimation(.linear(duration: 0.2)) {
                            if selection.contains(item) {
                                selection.remove(item)
                            } else {
                                selection.insert(item)
                            }
                        }
                    }
                }
            }
        }
    }
}
