//
//  ListFulfilmentView.swift
//  Shopper
//
//  Created by Illia Kniaziev on 04.05.2024.
//

import SwiftUI

struct ListFulfilmentView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var viewModel: ListFulfilmentViewModel
    
    var isSecondStepShown: Bool {
        viewModel.state != .products
    }
    
    var isSendingRequestShown: Bool {
        viewModel.state == .requesting
    }
    
    var body: some View {
        VStack {
            Text("Add your purchases to any shopping list")
                .font(.title3)
                .scaledToFit()
            
            Text("Select some lists in the order you want to fill them")
                .foregroundStyle(.gray)
                .font(.caption)
            
            FormProgressView()
                .padding(.vertical, 40)
                .frame(maxWidth: 300)
                .frame(height: 30)
            
            ListFormView()
            
            HStack {
                if viewModel.state == .lists {
                    ActionButton(title: "Back", disabled: false, action: viewModel.back)
                }
                
                ActionButton(title: isSecondStepShown ? "Submit" : "Next", disabled: !viewModel.canSubmit, action: viewModel.submit)
            }
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 20)
    }
    
    @ViewBuilder
    func FormProgressView() -> some View {
        HStack {
            Image(systemName: "1.circle")
                .foregroundStyle(Color.accentColor)
            
            Rectangle()
                .frame(height: 3)
                .background(Color.accentColor)
                .foregroundStyle(isSecondStepShown ? Color.accentColor : Color.gray)
            
            Image(systemName: "2.circle")
                .foregroundStyle(isSecondStepShown ? Color.accentColor : Color.gray)
            
            Rectangle()
                .frame(height: 3)
                .background(Color.accentColor)
                .foregroundStyle(isSendingRequestShown ? Color.accentColor : Color.gray)
            
            Group {
                if isSendingRequestShown {
                    ProgressView()
                } else {
                    Image(systemName: "checkmark.circle")
                }
            }
            .frame(width: 20)
        }
    }
    
    @ViewBuilder
    func ListFormView() -> some View {
        switch viewModel.state {
        case .products:
            Text("Select items to add to some list")
                .font(.caption)
                .foregroundStyle(Color.gray)
            
            List($viewModel.cartItems) { $item in
                HStack {
                    SelectionTile(id: item.id, showsOrder: true, selectedIds: $viewModel.selectedProductsIds)
                        .frame(width: 65)
                    
                    Divider()
                    
                    ProductPreviewView(
                        viewModel: .init(),
                        item: $item,
                        isEditable: .constant(true),
                        maxValue: viewModel.originalCount(forProductId: item.id),
                        isDeletable: false,
                        onDelete: {},
                        onUpdateFinished: {}
                    )
                }
            }
        case .lists, .requesting:
            Text("Select list in the order product will added")
                .font(.caption)
                .foregroundStyle(Color.gray)
            
            List(viewModel.shoppingLists) { item in
                HStack {
                    SelectionTile(id: item.id, showsOrder: false, selectedIds: $viewModel.selectedListsIds)
                        .frame(width: 65)
                    
                    Divider()
                    
                    Text(item.name)
                        .scaledToFit()
                }
            }
        }
    }
    
    @ViewBuilder
    func ActionButton(title: String, disabled: Bool, action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            HStack {
                Text(title)
                    .font(.system(.title3, weight: .semibold))
                    .foregroundColor(.white)
            }
            .frame(minWidth: 100, maxWidth: 260, minHeight: 42, maxHeight: 42, alignment: .center)
            .background(disabled ? Color.gray : Color.green)
            .cornerRadius(21)
        }
        .frame(maxWidth: .infinity)
        .disabled(disabled)
    }
}

struct SelectionTile: View {
    
    let id: String
    let showsOrder: Bool
    @Binding var selectedIds: [String]
    
    var body: some View {
        let isSelected = selectedIds.contains(id)
        Button {
            isSelected
            ? selectedIds.removeAll { $0 == id }
            : selectedIds.append(id)
        } label: {
            HStack {
                Image(systemName: isSelected ? "star.fill" : "star")
                if showsOrder, let index = selectedIds.firstIndex(of: id) {
                    Text(String(index + 1))
                        .fixedSize()
                }
            }
        }
    }
}

#Preview {
    ListFulfilmentView(
        viewModel: .init(
            shoppingLists: [],
            cartItems: [],
            onSubmit: { _, _ in }
        )
    )
}
