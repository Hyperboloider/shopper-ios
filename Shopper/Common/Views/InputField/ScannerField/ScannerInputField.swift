//
//  ScannerInputField.swift
//  Shopper
//
//  Created by Гіяна Князєва on 22.12.2022.
//

import SwiftUI
import VisionKit

struct ScannerInputField<FocusEnum: Hashable>: View {
    @FocusState var focusState: FocusEnum?
    @Binding var text: String

    let title: String
    let placeholder: String
    let focus: FocusEnum
    let onSubmit: () -> Void
    
    @StateObject private var model = ScannerFieldModel()
    @EnvironmentObject private var permissionManager: PermissonManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.system(.title2, weight: .semibold))
            
            HStack {
                TextField(placeholder, text: $text)
                
                Divider()
                    .overlay(.green)
                    .frame(height: 30)
                    .padding(.horizontal, 10)
                
                Button {
                    model.isScannerShown = true
                } label: {
                    Image(systemName: "barcode.viewfinder")
                }
                .padding(.trailing)
                
            }
                .font(.system(.title3))
                .frame(minHeight: 42)
                .padding(.leading, 20)
                .background {
                    Color.gray.opacity(0.2)
                }
                .cornerRadius(21)
                .overlay {
                    if focusState == focus {
                        RoundedRectangle(cornerRadius: 21)
                            .stroke(.green, lineWidth: 1)
                    }
                }
                .focused($focusState, equals: focus)
                .onSubmit {
                    onSubmit()
                }
        }
        .onChange(of: model.isScannerShown) { scanerShown in
            text = model.text
        }
        .sheet(isPresented: $model.isScannerShown) {
            if case .allGood = permissionManager.scannerPermissionStatus {
                BarcodeScanner(recognizedItems: $model.recentlyScannedCode)
                    .ignoresSafeArea()
            }
        }
        .task {
            await permissionManager.requestPermission()
        }
    }
}
