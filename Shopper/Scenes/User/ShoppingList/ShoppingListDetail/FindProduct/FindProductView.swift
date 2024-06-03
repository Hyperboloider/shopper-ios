//
//  FindProductView.swift
//  Shopper
//
//  Created by Illia Kniaziev on 12.05.2024.
//

import Foundation
import SwiftUI

struct FindProductView: View {
    
    private enum FieldType {
        case upc
    }
    
    @StateObject var viewModel: FindProductViewModel
    @Environment(\.presentationMode) private var presentationMode
    @FocusState private var activeField: FieldType?
    
    var body: some View {
        NavigationView {
            VStack {
                if let result = viewModel.result {
                    VStack(alignment: .leading) {
                        Label(result.name, systemImage: "basket")
                            .font(.system(.title2, weight: .semibold))
                        
                        Text(result.id)
                            .font(.system(.title3))
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: 260, alignment: .leading)
                    .padding(.horizontal, 32)
                }
                
                VStack {
                    HStack {
                        HLine()
                            .stroke(style: StrokeStyle(lineWidth: 1, dash: [4]))
                            .foregroundColor(.green)
                        
                        Text("Or scan UPC")
                            .font(.system(.title3, weight: .semibold))
                            .padding(10)
                            .background { Color.primary.colorInvert() }
                            .fixedSize()
                        
                        HLine()
                            .stroke(style: StrokeStyle(lineWidth: 1, dash: [4]))
                            .foregroundColor(.green)
                    }
                    .frame(height: 50)
                    
                    ScannerInputField(focusState: _activeField, text: $viewModel.upc, title: "", placeholder: "Barcode data here", focus: .upc) {
                        activeField = nil
                        viewModel.submit()
                    }
                }
                
                Spacer()
                    .frame(height: 50)
                
                Button {
                    withAnimation {
                        viewModel.submit()
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
                    .background(viewModel.canSubmit ? Color.green : Color.gray)
                    .cornerRadius(21)
                }
                .disabled(!viewModel.canSubmit)
                
                Spacer()
            }
            .padding()
        }
        .alert("Product does not exist", isPresented: $viewModel.isAlertShown) {
            Button("OK", role: .cancel) {}
        }
        .searchable(text: $viewModel.searchQuery, prompt: "Find product")
        .searchSuggestions {
            ForEach(viewModel.searchResults, id:\.self) { result in
                Button(result.name) {
                    viewModel.result = result
                }
            }
        }
        .onChange(of: viewModel.networkingState) { newValue in
            if newValue == .success {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}
