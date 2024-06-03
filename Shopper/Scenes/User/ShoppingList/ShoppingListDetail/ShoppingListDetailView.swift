//
//  ShoppingListDetailView.swift
//  Shopper
//
//  Created by Illia Kniaziev on 26.04.2024.
//

import SwiftUI
import UIKit

struct ShoppingListDetailView: View {
    
    @State var isAdding = false
    @State var isManagingUsers = false
    @StateObject var viewModel: ShoppingListDetailViewModel
    
    var body: some View {
        WaitingView(refetchAction: viewModel.fetchList, networkStatePublisher: viewModel.$networkingState.eraseToAnyPublisher()) {
                List {
                    ForEach($viewModel.products) { $item in
                        VStack {
                            ProductPreviewView(
                                viewModel: .init(),
                                item: $item.product,
                                isEditable: $viewModel.isEditing,
                                onDelete: {
                                    viewModel.handleDeletion(item: item.product)
                                    viewModel.handleEdit()
                                },
                                onUpdateFinished: {
                                    viewModel.handleEdit()
                                }
                            )
                            
                            if item.product.product.isPricePerKilo {
                                ProgressView(
                                    "\(formattedFractionNumber(item.bought)) of \(formattedFractionNumber(item.amount))",
                                    value: item.bought,
                                    total: item.amount
                                )
                                .padding(.bottom, 12)
                            } else {
                                ProgressView(
                                    "\(Int(item.bought)) of \(Int(item.amount))",
                                    value: item.bought,
                                    total: item.amount
                                )
                                .padding(.bottom, 12)
                            }
                        }
                    }
                    
                    if viewModel.isEditing {
                        Group {
                            Button {
                                withAnimation {
                                    isAdding.toggle()
                                }
                            } label: {
                                HStack {
                                    Text("Add")
                                        .font(.system(.title3, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                                .frame(minWidth: 100, maxWidth: 260, minHeight: 42, maxHeight: 42, alignment: .center)
                                .background(Color.green)
                                .cornerRadius(21)
                            }
                            .frame(maxWidth: .infinity)
                            
                            Button {
                                withAnimation {
                                    viewModel.handleUpdate()
                                }
                            } label: {
                                HStack {
                                    Text("Submit")
                                        .font(.system(.title3, weight: .semibold))
                                        .foregroundColor(.white)
                                    
                                    if case .waiting = viewModel.networkingState {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .padding(.leading, 3)
                                    }
                                }
                                .frame(minWidth: 100, maxWidth: 260, minHeight: 42, maxHeight: 42, alignment: .center)
                                .background(viewModel.canUpdate ? Color.green : Color.gray)
                                .cornerRadius(21)
                            }
                            .frame(maxWidth: .infinity)
                            .disabled(!viewModel.canUpdate)
                            .listRowBackground(Color.clear)
                        }
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                    }
                }
        }
        .toolbar {
            if viewModel.isEditable {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    if !viewModel.isEditing {
                        Button {
                            viewModel.shareInvitation()
                        } label: {
                            Image(systemName: "envelope")
                        }
                        
                        if viewModel.detailedList?.users.isEmpty == false {
                            Button {
                                isManagingUsers = true
                            } label: {
                                Image(systemName: "person.3")
                            }
                        }
                    }
                    
                    Button {
                        viewModel.isEditing.toggle()
                        if viewModel.isEditing {
                            viewModel.saveState()
                        } else {
                            viewModel.resetState()
                        }
                    } label: {
                        Image(systemName: viewModel.isEditing ? "arrow.uturn.backward.circle" : "pencil")
                    }
                }
            }
        }
        .navigationTitle(viewModel.detailedList?.name ?? "")
        .sheet(isPresented: $isAdding) {
            FindProductView(viewModel: .init(networkingService: viewModel.networkingService, onSubmit: viewModel.handleAddition))
        }
        .sheet(isPresented: $isManagingUsers) {
            UserManagementView(
                viewModel: .init(
                    networkingService: viewModel.networkingService,
                    listId: viewModel.listId,
                    userIds: viewModel.detailedList?.users ?? []
                )
            )
        }
        .onChange(of: viewModel.sharedLink) { _ in
            guard let url = viewModel.sharedLink else { return }
            share(url: url)
        }
        .onChange(of: viewModel.products) { _ in
            isAdding = false
        }
        .onChange(of: viewModel.detailedList) { _ in
            viewModel.isEditing = false
        }
        .onAppear {
            viewModel.fetchList()
        }
    }
    
    func formattedFractionNumber(_ number: Double) -> String {
        let divisor = 0.05
        let value = (number / divisor).rounded() * divisor
        return String(format: "%g", value)
    }
    
    func share(url: URL) {
        let vc = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        window?.rootViewController?.present(vc, animated: true)
    }
}

#Preview {
    NavigationView {
        ShoppingListDetailView(viewModel: .init(networkingService: NetworkingService(), listId: "", isOwnList: true))
            .environmentObject(PermissonManager())
    }
}
