//
//  TagFilterView.swift
//  Shopper
//
//  Created by Гіяна Князєва on 21.12.2022.
//

import SwiftUI

struct TagFilterView<T: Taggable>: View {
    var tags: [T] = []
    let placeholder: String
    let isSingleSelection: Bool

    @Binding var selectedTags: [T]
    @Binding var excludedTags: [T]
    
    @State private var keyword: String = ""
        
    var body: some View {
        VStack {
            SearchView()
                .fixedSize(horizontal: false, vertical: true)
            
            SearchResultView()
        }
    }
    
    @ViewBuilder
    func SearchView() -> some View {
        HStack(alignment: .top, spacing: 10) {
            TagTextField(tags: $selectedTags, keyword: $keyword, placeholder: placeholder) { _ in
                return tags
                    .filter{ $0.displayName.contains(keyword.lowercased()) }
                    .first
            }
            .frame(minHeight: 30)
            .padding(.horizontal)
            .padding(.vertical, 6)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(20)
        }
    }
    
    @ViewBuilder
    func SearchResultView() -> some View {
        let filteredTags = tags
            .filter { !excludedTags.contains($0) }
            .filter { !selectedTags.contains($0) }
            .filter { $0.displayName.contains(keyword.lowercased()) }
        
        List {
            ForEach(filteredTags, id: \.self) { tag in
                Button {
                    if !selectedTags.contains(tag) {
                        if isSingleSelection {
                            selectedTags.removeAll()
                        }
                        selectedTags.append(tag)
                    }
                    keyword.removeAll()
                } label: {
                    Text(tag.displayName)
                }
            }
        }
        .listStyle(.plain)
        .frame(height: filteredTags.isEmpty ? 0 : 150)
    }
}

struct TagFilterView_Previews: PreviewProvider {
    static let tags = ["Java", "Python", "JavaScript", "Php", "Swift", "SQL", "Ruby", "Objective-C", "Go", "Assembly", "Basic", "Html", "React", "Kotlin", "C++", "C#"].map { $0.lowercased() }
    static var previews: some View {
        TagFilterView(tags: tags, placeholder: "Tags", isSingleSelection: true, selectedTags: .constant([]), excludedTags: .constant(["swift"]))
    }
}

