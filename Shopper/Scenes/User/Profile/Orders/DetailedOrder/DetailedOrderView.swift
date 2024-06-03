//
//  DetailedOrderView.swift
//  Shopper
//
//  Created by Гіяна Князєва on 24.12.2022.
//

import SwiftUI

struct DetailedOrderView: View {
    
    @StateObject var viewModel: DetailedOrderViewModel
    
    var body: some View {
        VStack {
            switch viewModel.networkingState {
            case .waiting:
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .secondary))
                    .scaleEffect(x: 2, y: 2)
            case .failure(_):
                Button {
                    viewModel.fetchOrder()
                } label: {
                    Label("Try again", systemImage: "arrow.clockwise")
                }
            case .none, .success:
                if let products = viewModel.detailedOrder?.products {
                    List(products) { product in
                        NavigationLink {
                            DetailedProductView(product: product.product)
                        } label: {
                            CompactProductPreviewView(item: product)
                        }
                    }
                }
            }
        }
    }
}

struct DetailedOrderView_Previews: PreviewProvider {
    static var previews: some View {
        DetailedOrderView(viewModel: DetailedOrderViewModel(networkingService: NetworkingService(), orderId: "ss"))
    }
}
