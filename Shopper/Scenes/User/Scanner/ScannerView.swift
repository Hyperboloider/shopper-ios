//
//  ScannerView.swift
//  Shopper
//
//  Created by Illia Kniaziev on 19.12.2022.
//

import SwiftUI
import VisionKit

struct ScannerView: View {
    
    @StateObject var viewModel: ScannerViewModel
    @State private var isPreviewVisible = true
    @EnvironmentObject private var shoppingCart: ShoppingCart
    @EnvironmentObject private var permissionManager: PermissonManager
    
    var body: some View {
        VStack {
            if case .allGood = permissionManager.scannerPermissionStatus {
                BarcodeView()
                    .overlay {
                        if !isPreviewVisible {
                            VStack {
                                Spacer()
                                
                                HStack {
                                    Spacer()
                                    
                                    Button {
                                        isPreviewVisible.toggle()
                                    } label: {
                                        Image(systemName: "basket.fill")
                                            .scaleEffect(1.2)
                                            .foregroundColor(.green)
                                            .padding()
                                            .background { Color.white }
                                            .clipShape(Circle())
                                            .padding(40)
                                    }

                                }
                            }
                        }
                    }
            } else {
                Text(permissionManager.scannerPermissionStatus.rawValue)
            }
        }
        .task {
            await permissionManager.requestPermission()
        }
    }
    
    @ViewBuilder
    func BarcodeView() -> some View {
        BarcodeScanner(recognizedItems: $viewModel.recentlyScannedCode)
            .background { Color.gray.opacity(0.3) }
            .edgesIgnoringSafeArea(.top)
            .sheet(isPresented: $isPreviewVisible) {
                ProductsPreview()
                    .presentationDetents([.fraction(0.25), .fraction(0.65)])
                    .presentationDragIndicator(.visible)
                    .background(.ultraThinMaterial)
                    .onAppear {
                        guard
                            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                            let controller = windowScene.windows.first?.rootViewController?.presentedViewController
                        else {
                            return
                        }
                        
                        controller.view.backgroundColor = .clear
                    }
            }
    }
    
    @ViewBuilder
    func ProductsPreview() -> some View {
        List {
            ForEach(0..<max(0, viewModel.pendingRequests), id:\.self) { _ in
                ProductPlaceholder()
            }
            
            ForEach($shoppingCart.products) { $item in
                ProductPreviewView(viewModel: ProductPreviewModel(), item: $item) {
                    shoppingCart.delete(item: item)
                } onUpdateFinished: {
                    shoppingCart.saveToDraft()
                }

            }
        }
    }
    
}
