//
//  DeleteCategoryView.swift
//  Shopper
//
//  Created by Гіяна Князєва on 22.12.2022.
//

import SwiftUI

struct DeleteCategoryView: View {
    
    @StateObject var viewModel: DeleteCategoryViewModel
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        VStack {
            VStack(spacing: 5) {
                VStack(alignment: .leading) {
                    Text("Category")
                        .font(.system(.title2, weight: .semibold))
                    
                    TagFilterView(
                        tags: viewModel.categories,
                        placeholder: "Category",
                        isSingleSelection: true,
                        selectedTags: $viewModel.selectedCategories,
                        excludedTags: .constant([]))
                }
                
                Button {
                    withAnimation {
                        viewModel.submit()
                    }
                } label: {
                    HStack {
                        Text("Delete")
                            .font(.system(.title3, weight: .semibold))
                            .foregroundColor(.white)
                        
                        if case .waiting = viewModel.networkingState {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .padding(.leading, 3)
                        }
                    }
                    .frame(minWidth: 100, maxWidth: 260, minHeight: 42, maxHeight: 42, alignment: .center)
                    .background(viewModel.selectedCategories.isEmpty ? Color.gray : Color.green)
                    .cornerRadius(21)
                }
                .disabled(viewModel.selectedCategories.isEmpty)
            }
            .padding()
            
            Spacer()
        }
        .alert("Category no longer exists", isPresented: $viewModel.isCategoryNotExisting) {
            Button("OK", role: .cancel) {}
        }
        .onChange(of: viewModel.networkingState) { newValue in
            if newValue == .success {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

struct DeleteCategoryView_Previews: PreviewProvider {
    static var previews: some View {
        DeleteCategoryView(viewModel: DeleteCategoryViewModel(networkingService: NetworkingService(), categories: [
            Category(response: CategoryResponse(id: "fuzzy drinks")),
            Category(response: CategoryResponse(id: "fuzzy drinks"))
        ]))
    }
}
