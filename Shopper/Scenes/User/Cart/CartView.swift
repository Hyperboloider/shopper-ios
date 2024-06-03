//
//  CartView.swift
//  Shopper
//
//  Created by Гіяна Князєва on 20.12.2022.
//

import SwiftUI
import RealmSwift

struct CartView: View {
    
    @StateObject var viewModel: CartViewModel
    @EnvironmentObject var shoppingListModel: ShoppingListModel
    @EnvironmentObject private var shoppingCart: ShoppingCart
    @EnvironmentObject private var networkingService: NetworkingService
    @State private var isThankYouShown = false
    @State private var isShoppingListPromptShown = false
    @ObservedResults(Category.self) private var categories
    
    init(viewModel: CartViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    @State private var total = 0.0
    @State private var number = 0.0
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    if viewModel.networkingState != .waiting, !shoppingCart.isRestoring {
                        Section {
                            ModeToggler()
                        }
                        
                        if viewModel.isDynamicAdjastmentEnabled, !viewModel.similarCarts.isEmpty {
                            let index = Int(viewModel.selectedSimilarCartIndex)
                            let similarCart = viewModel.similarCarts[index]
                            
                            ForEach(similarCart.items) { item in
                                NavigationLink {
                                    DetailedProductView(product: item.product)
                                } label: {
                                    SuggestedProductPreviewView(product: item.product)
                                }
                            }
                            
                            Section("Adjust basket price") {
                                AdjastmentSlider()
                            }
                        } else {
                            ForEach($shoppingCart.products) { $item in
                                NavigationLink {
                                    DetailedProductView(product: item.product)
                                } label: {
                                    ProductPreviewView(viewModel: ProductPreviewModel(), item: $item) {
                                        shoppingCart.delete(item: item)
                                    } onUpdateFinished: {
                                        shoppingCart.saveToDraft()
                                    }
                                }
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
                
                if viewModel.isDynamicAdjastmentEnabled {
                    Button {
                        DispatchQueue.main.async {
                            viewModel.isDynamicAdjastmentEnabled = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
                                withAnimation {
                                    shoppingCart.removeAll()
                                    let index = Int(viewModel.selectedSimilarCartIndex)
                                    let cart = viewModel.similarCarts[index]
                                    cart.items.forEach { shoppingCart.append($0.product, quantity: $0.amount) }
                                }
                            }
                        }
                    } label: {
                        Text("Submit")
                            .font(.system(.title))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 70)
                    }
                    .background {
                        Color.green
                            .cornerRadius(10)
                            .padding(.horizontal, 20)
                    }
                } else if !shoppingCart.products.isEmpty {
                    TotalView()
                }
            }
            .overlay(alignment: .center) {
                VStack {
                    if viewModel.networkingState == .waiting {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .secondary))
                    } else if isThankYouShown {
                        Label("Your order was successfully added!", systemImage: "checkmark")
                    } else if shoppingCart.products.isEmpty {
                        VStack {
                            Group {
                                Text("The cart is empty.")
                                Text("It's time to add something yummy! 🥑")
                            }
                            .foregroundColor(.secondary)
                        }
                    }
                }
                .offset(y: -70)
            }
            .searchable(text: $viewModel.searchQuery, prompt: "Find product")
            .searchSuggestions {
                ForEach(viewModel.searchResults, id:\.self) { product in
                    Button(product.name) {
                        shoppingCart.append(product)
                    }
                }
            }
            .onChange(of: shoppingCart.products) { _ in
                countCheck()
            }
            .onAppear {
                countCheck()
            }
        }
        .onChange(of: viewModel.isDynamicAdjastmentEnabled) { flag in
            if flag {
                shoppingCart.cacheItems()
            } else {
                shoppingCart.restoreItems()
            }
        }
        .onChange(of: viewModel.networkingState) { newValue in
            if newValue == .success {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    shoppingCart.removeAll()
                }
                isThankYouShown = true
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(10)) {
                    withAnimation {
                        self.isThankYouShown = false
                    }
                }
            }
        }
        .onAppear {
            shoppingCart.restoreFromDraft()
        }
        .sheet(isPresented: $isShoppingListPromptShown) {
            let model = ListFulfilmentViewModel(
                shoppingLists: Array(shoppingListModel.ownShoppingLists) + Array(shoppingListModel.otherShoppingLists),
                cartItems: shoppingCart.products,
                onSubmit: {
                    shoppingListModel.fulfilLists(
                        products: $0,
                        lists: $1,
                        completion: {
                            isShoppingListPromptShown = false
                        }
                    )
                }
            )
            ListFulfilmentView(
                viewModel: model
            )
        }
    }
    
    func countCheck() {
        total = shoppingCart.products
            .reduce(0.0) { $0 + $1.product.price * Double($1.amount) }
        
        number = shoppingCart.products
            .reduce(0.0) { $0 + $1.amount }
    }
    
    @ViewBuilder
    private func ModeToggler() -> some View {
        GeometryReader { proxy in
            HStack {
                Button {
                    viewModel.isDynamicAdjastmentEnabled.toggle()
                    if viewModel.isDynamicAdjastmentEnabled {
                        viewModel.fetchSimilarCarts(cart: shoppingCart.products)
                    }
                } label: {
                    Label("Adjustment", systemImage: "ruler")
                        .foregroundColor(viewModel.isDynamicAdjastmentEnabled ? nil : .secondary)
                        .environment(\.layoutDirection, .rightToLeft)
                }
                .frame(maxWidth: proxy.size.width * 0.45)
                .disabled(shoppingCart.products.isEmpty)
                
                Spacer()
                
                Divider()
                    .overlay(.black)
                
                Spacer()
                
                NavigationLink {
                    CartOptimizationView(viewModel: CartOptimizationViewModel(networgingService: networkingService, categories: Array(categories)))
                } label: {
                    Label("Autofill", systemImage: "basket")
                    .frame(maxWidth: proxy.size.width * 0.45)
                }
                .disabled(viewModel.isDynamicAdjastmentEnabled)
            }
            .buttonStyle(.plain)
        }
        .frame(height: 40)
    }
    
    @ViewBuilder
    private func AdjastmentSlider() -> some View {
        VStack(spacing: 0) {
            HStack {
                ForEach(Array(viewModel.similarCarts.enumerated()), id:\.offset) { index, cart in
                    UAHView(total: cart.price)
                        .font(.system(.footnote))
                        .foregroundColor(index == Int(viewModel.selectedSimilarCartIndex) ? .primary : .secondary)
                    
                    if index != viewModel.similarCarts.count - 1 {
                        Spacer()
                    }
                }
            }
            
            if viewModel.similarCarts.count > 1 {
                Slider(value: $viewModel.selectedSimilarCartIndex,
                       in: 0...Double(viewModel.similarCarts.count - 1),
                       step: 1)
                .padding(.horizontal)
            }
        }
    }
    
    @ViewBuilder
    private func TotalView() -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(String(format: "%g", number))
                    .font(.system(.title2, weight: .bold))
                +
                Text(number == 1 ? " item" : " items")
                    .font(.system(.title2))
                
                HStack(spacing: 0) {
                    Text("For ")
                        .font(.system(.title))
                    
                    UAHView(total: total)
                        .font(.system(.title, weight: .bold))
                        .minimumScaleFactor(0.1)
                }
            }
            
            Spacer(minLength: 10)
            
            Button {
                viewModel.sendOrder(purchases: shoppingCart.products) {
                    guard !shoppingListModel.ownShoppingLists.isEmpty || !shoppingListModel.otherShoppingLists.isEmpty
                    else { return }
                    isShoppingListPromptShown = true
                }
            } label: {
                EmptyView()
            }
            .cornerRadius(10)
            .buttonStyle(ApplePayButtonStyle())
            .frame(height: 50)
            .frame(maxWidth: 200)
            .padding(1)
            .background {
                Color.white
                    .cornerRadius(10)
            }
            .disabled(shoppingCart.products.isEmpty)
        }
        .padding(.horizontal, 20)
        .frame(height: 70)
    }
}

struct CartView_Previews: PreviewProvider {
    
    static let cart: ShoppingCart = {
        let items = [
            ShoppingCartItem(product: ProductResponse(
            id: "jknfwelkf",
            name: "Coca-Cola Zero 0.5",
            description: "Sugar-free Coke.",
            upc: "123445312345",
            pricePerKilo: 15.10, weightPerItem: 1,
            isPricePerKilo: false,
            caloriesPer100g: 0,
            protein: 0,
            fat: 0,
            carb: 0,
            category: "fuzzy drinks", imageUrl: "")),
            ShoppingCartItem(product: ProductResponse(
            id: "kfsdlksfad",
            name: "Sprite 0.5",
            description: "Sugar-free Coke.",
            upc: "2323423324234",
            pricePerKilo: 14.90, weightPerItem: 1,
            isPricePerKilo: false,
            caloriesPer100g: 230,
            protein: 1,
            fat: 2,
            carb: 9,
            category: "fuzzy drinks", imageUrl: ""))
        ]
        let cart = ShoppingCart(cartRestorationService: .init(networkingService: NetworkingService()))
        cart.products = items
        return cart
    }()
    
    static var previews: some View {
        CartView(viewModel: .init(networkingService: NetworkingService()))
            .environmentObject(cart)
    }
}
