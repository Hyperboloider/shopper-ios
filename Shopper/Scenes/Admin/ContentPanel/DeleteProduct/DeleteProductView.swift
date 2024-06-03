//
//  DeleteProductView.swift
//  Shopper
//
//  Created by Гіяна Князєва on 22.12.2022.
//

import SwiftUI

struct DeleteProductView: View {
    
    private enum FieldType {
        case upc
    }
    
    @StateObject var viewModel: DeleteProductViewModel
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

struct DeleteProductView_Previews: PreviewProvider {
    static var previews: some View {
        DeleteProductView(viewModel: DeleteProductViewModel(networkingService: NetworkingService()))
            .environmentObject(PermissonManager())
    }
}
