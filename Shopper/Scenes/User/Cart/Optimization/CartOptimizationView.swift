//
//  CartOptimizationView.swift
//  Shopper
//
//  Created by Гіяна Князєва on 21.12.2022.
//

import SwiftUI

struct CartOptimizationView: View {
    
    @StateObject var viewModel: CartOptimizationViewModel
    @EnvironmentObject private var shoppingCart: ShoppingCart
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 50) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Max")
                        .font(.system(.title2, weight: .semibold))

                    TagPicker(
                        dataSource: viewModel.objectives,
                        selection: $viewModel.selectedMax,
                        unavailable: $viewModel.selectedMin)
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("Min")
                        .font(.system(.title2, weight: .semibold))

                    TagPicker(
                        dataSource: viewModel.objectives,
                        selection: $viewModel.selectedMin,
                        unavailable: $viewModel.selectedMax)
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("Category")
                        .font(.system(.title2, weight: .semibold))
                    
                    TagFilterView(
                        tags: viewModel.categories,
                        placeholder: "Category",
                        isSingleSelection: false,
                        selectedTags: $viewModel.selectedCategories,
                        excludedTags: .constant([]))
                }
                
                SubmitButton(networkingState: $viewModel.networkingState, canSubmit: .constant(true), title: "Search") {
                    viewModel.optimise()
                }
                .disabled(viewModel.selectedCategories.isEmpty || viewModel.selectedMax.isEmpty && viewModel.selectedMin.isEmpty)
                
                if !viewModel.suggestedProducts.isEmpty {
                    VStack(alignment: .leading) {
                        Text("Suggestions")
                            .font(.system(.title2, weight: .semibold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        VStack {
                            ForEach(viewModel.suggestedProducts) { product in
                                let contains = shoppingCart.products.contains { $0.product == product }
                                HStack {
                                    NavigationLink {
                                        DetailedProductView(product: product
                                        )
                                    } label: {
                                        SuggestedProductPreviewView(product: product)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "xmark.circle.fill")
                                        .renderingMode(.template)
                                        .foregroundColor(.white)
                                        .scaleEffect(x: 2, y: 2)
                                        .rotationEffect(contains ? .zero : .degrees(45))
                                        .background {
                                            (contains ? Color.gray : Color.green)
                                                .cornerRadius(10)
                                        }
                                        .onTapGesture {
                                            withAnimation(.linear(duration: 0.15)) {
                                                if contains {
                                                    shoppingCart.delete(item: ShoppingCartItem(product: product))
                                                } else {
                                                    shoppingCart.append(product)
                                                }
                                            }
                                        }
                                }
                                .contentShape(Rectangle())
                            }
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
        }
    }
}
