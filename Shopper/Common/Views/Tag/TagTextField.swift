//
//  TagTextField.swift
//  Shopper
//
//  Created by Гіяна Князєва on 21.12.2022.
//

import SwiftUI
import UIKit

struct TagTheme {
    var font: Font = Font.system(size: 14)
    var foregroundColor: Color = .black
    var backgroundColor: Color = Color.white
    var borderColor: Color = .gray
    var shadowColor: Color = .gray
    var shadowRadius: CGFloat = 5
    var cornerRadius: CGFloat = 13
    
    var deletable: Bool = true
    var deleteButtonSize: CGFloat = 12
    var deleteButtonColor: Color = .gray
    var deleteButtonSystemImageName: String = "xmark.circle.fill"
    
    var spacing: CGFloat = 5.0
    var alignment: HorizontalAlignment = .leading
    
    var inputFieldFont: Font = .system(size: 14)
    var inputFieldTextColor: Color = .primary
    
    var contentInsets: EdgeInsets = EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10)
}

struct TagTextField<T: Taggable>: View {
    @Binding var tags: [T]
    @Binding var keyword: String
    
    var theme: TagTheme = TagTheme()
    var placeholder: String = ""
    var checkKeyword: (String) -> T?
        
    @State private var availableWidth: CGFloat = 0
    @State private var elementsSize: [T: CGSize] = [:]
    
    var body: some View {
        ZStack(alignment: Alignment(horizontal: theme.alignment, vertical: .center)) {
            Color.clear
                .frame(height: 1)
                .readSize { size in
                    availableWidth = size.width
                }
            
            TagsContainer()
        }
    }
    
    @ViewBuilder
    private func TagsContainer() -> some View {
        let rows = computeRows()
        
        VStack(alignment: theme.alignment, spacing: theme.spacing) {
            ForEach(0..<rows.count, id: \.self) { index in
                HStack(spacing: theme.spacing) {
                    ForEach(rows[index], id: \.self) { element in
                        TagView(tag: element, theme: theme) {
                            withAnimation {
                                tags.removeAll(where: {$0 == element})
                            }
                        }
                        .fixedSize()
                        .readSize { size in
                            elementsSize[element] = size
                        }
                    }
                    
                    if index == rows.count - 1 {
                        TextInputView()
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func TextInputView() -> some View {
        TextField(placeholder, text: $keyword, onCommit: {
            if !keyword.isEmpty, let result = checkKeyword(keyword), !tags.contains(result) {
                tags.append(result)
            }
            keyword.removeAll()
        })
        .textFieldStyle(PlainTextFieldStyle())
        .foregroundColor(theme.inputFieldTextColor)
        .disableAutocorrection(true)
        .autocapitalization(.none)
    }
    
    private func computeRows() -> [[T]] {
        var rows: [[T]] = [[]]
        var currentRow = 0
        var remainingWidth = availableWidth
        
        for element in tags {
            let elementSize = elementsSize[element, default: CGSize(width: availableWidth, height: 1)]
            
            if remainingWidth - (elementSize.width + theme.spacing) >= 0 {
                rows[currentRow].append(element)
            } else {
                currentRow = currentRow + 1
                rows.append([element])
                remainingWidth = availableWidth
            }
            remainingWidth = remainingWidth - (elementSize.width + theme.spacing)
        }
        return rows
    }
}

private struct TagView<T: Taggable>: View {
    let tag: T
    let theme: TagTheme
    var deleteAction: (() -> Void) = {}
        
    public var body: some View {
        HStack (spacing: 4) {
            Text(tag.displayName)
                .font(theme.font)
                .foregroundColor(theme.foregroundColor)
            if theme.deletable {
                Button {
                    deleteAction()
                } label: {
                    Image(systemName: theme.deleteButtonSystemImageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(theme.deleteButtonColor)
                        .frame(width: theme.deleteButtonSize, height: theme.deleteButtonSize)
                }
            }
        }
        .padding(theme.contentInsets)
        .background(theme.backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: theme.cornerRadius).stroke(theme.borderColor, lineWidth: 1.0)
                .shadow(color: theme.shadowColor, radius: theme.shadowRadius)
        )
    }
}

private struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) { /* empty */ }
}

private extension View {
    func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
        background(
            GeometryReader { geometryProxy in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: geometryProxy.size)
            }
        )
        .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
    }
}


