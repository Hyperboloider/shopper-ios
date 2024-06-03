//
//  OrdersView.swift
//  Shopper
//
//  Created by Гіяна Князєва on 24.12.2022.
//

import SwiftUI

struct OrdersView: View {
    
    private enum Field {
        case id
    }
    
    @StateObject var viewModel: OrdersViewModel
    @EnvironmentObject private var networkingService: NetworkingService
    @FocusState private var activeField: Field?
    
    var body: some View {
        List {
            if viewModel.shouldShowInputPrompt {
                Section() {
                    VStack {
                        ScannerInputField(focusState: _activeField, text: $viewModel.userId, title: "Scan user's code in the profile", placeholder: "user identifier", focus: .id) {
                            activeField = nil
                            viewModel.fetchOrders()
                        }
                        .padding(.bottom)
                        
                        Button {
                            withAnimation {
                                viewModel.fetchOrders()
                            }
                        } label: {
                            HStack {
                                Text("Fetch")
                                    .font(.system(.title3, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                if case .waiting = viewModel.networkingState {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .padding(.leading, 3)
                                }
                            }
                            .frame(minWidth: 100, maxWidth: 260, minHeight: 42, maxHeight: 42, alignment: .center)
                            .background(!viewModel.userId.isEmpty ? Color.green : Color.gray)
                            .cornerRadius(21)
                        }
                        .disabled(viewModel.userId.isEmpty)
                        .padding(.bottom)
                    }
                    .buttonStyle(.plain)
                }
            }
            
            Section {
                if viewModel.shouldShowInputPrompt, !viewModel.lastUsedId.isEmpty {
                    Text("Orders for user with ID: ")
                    +
                    Text(viewModel.lastUsedId)
                        .font(.system(.body, weight: .semibold))
                }
                
                ForEach(viewModel.orders) { order in
                    NavigationLink {
                        DetailedOrderView(viewModel: DetailedOrderViewModel(networkingService: networkingService, orderId: order.id))
                    } label: {
                        OrderPreview(for: order)
                    }

                }
                
                if !viewModel.shouldShowInputPrompt, viewModel.networkingState == .waiting {
                    ProgressView()
                } else if viewModel.orders.isEmpty {
                    Text("No orders yet 🍉")
                }
            }
        }
    }
    
    @ViewBuilder
    private func OrderPreview(for order: OrderResponse) -> some View {
        VStack(alignment: .leading) {
            let number = order.products.count
            Text("\(number) \(number == 1 ? "product" : "products")")
                .font(.system(.title3, weight: .semibold))
            
            Text(description(forDate: order.creationDate))
                .foregroundColor(.primary.opacity(0.7))
        }
    }
    
    private func description(forDate date: Date) -> String {
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            return "Today at \(date.formatted(.dateTime.hour().minute()))"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday at \(date.formatted(.dateTime.hour().minute()))"
        } else {
            return date.formatted(.dateTime.day().month().year().hour().minute())
        }
    }
}

struct OrdersView_Previews: PreviewProvider {
    static var previews: some View {
        OrdersView(viewModel: OrdersViewModel(networkingService: NetworkingService(), initialUserId: "assa"))
            .environmentObject(PermissonManager())
        
        OrdersView(viewModel: OrdersViewModel(networkingService: NetworkingService(), shouldShowInputPrompt: true))
            .environmentObject(PermissonManager())
    }
}
