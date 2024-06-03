//
//  ContentPanelView.swift
//  Shopper
//
//  Created by Гіяна Князєва on 21.12.2022.
//

import SwiftUI
import RealmSwift

struct ContentPanelView: View {
    
    @EnvironmentObject private var networkingService: NetworkingService
    @ObservedResults(Category.self) var categories
    
    var body: some View {
        NavigationView {
            List {
                Section("Products management") {
                    NavigationLink {
                        AddProductView(viewModel: AddProductViewModel(networkingService: networkingService, categories: Array(categories)))
                    } label: {
                        Label("Add product", systemImage: "bag.badge.plus")
                    }
                    
                    NavigationLink {
                        DeleteProductView(viewModel: DeleteProductViewModel(networkingService: networkingService))
                    } label: {
                        Label {
                            Text("Delete product")
                        } icon: {
                            Image(systemName: "bag.badge.minus")
                                .foregroundColor(.red)
                        }
                    }
                }
                    
                Section("Cetegories management") {
                    NavigationLink {
                        AddCategoryView(viewModel: AddCategoryViewModel(networkingService: networkingService))
                    } label: {
                        Label("Add category", systemImage: "tag")
                    }
                    
                    NavigationLink {
                        DeleteCategoryView(viewModel: DeleteCategoryViewModel(networkingService: networkingService, categories: Array(categories)))
                    } label: {
                        Label {
                            Text("Delete category")
                        } icon: {
                            Image(systemName: "tag.slash")
                                .foregroundColor(.red)
                        }
                    }
                }
                
                Section("Client info") {
                    NavigationLink {
                        OrdersView(viewModel: OrdersViewModel(networkingService: networkingService, shouldShowInputPrompt: true))
                        // 639f592c9b29037434ea2d07
                    } label: {
                        Label {
                            Text("Get client's orders")
                        } icon: {
                            Image(systemName: "list.bullet.clipboard")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
        }
    }
}

struct ContentPanelView_Previews: PreviewProvider {
    static var previews: some View {
        ContentPanelView()
    }
}
