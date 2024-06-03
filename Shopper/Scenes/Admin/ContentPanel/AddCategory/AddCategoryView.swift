//
//  AddCategoryView.swift
//  Shopper
//
//  Created by Гіяна Князєва on 22.12.2022.
//

import SwiftUI

struct AddCategoryView: View {
    
    private enum FieldType {
        case name
    }
    
    @StateObject var viewModel: AddCategoryViewModel
    @Environment(\.presentationMode) private var presentationMode
    @FocusState private var activeField: FieldType?
    
    var body: some View {
        VStack {
            InputField(focusState: _activeField, text: $viewModel.name, title: "Name", placeholder: "meat", focus: .name) {
                if !viewModel.name.isEmpty {
                    viewModel.submit()
                }
            }
            
            Button {
                withAnimation {
                    viewModel.submit()
                }
            } label: {
                HStack {
                    Text("Create")
                        .font(.system(.title3, weight: .semibold))
                        .foregroundColor(.white)
                    
                    if case .waiting = viewModel.networkingState {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .padding(.leading, 3)
                    }
                }
                .frame(minWidth: 100, maxWidth: 260, minHeight: 42, maxHeight: 42, alignment: .center)
                .background(viewModel.name.isEmpty ? Color.gray : Color.green)
                .cornerRadius(21)
            }
            .disabled(viewModel.name.isEmpty)
            
            Spacer()
        }
        .frame(minWidth: 100, maxWidth: 260, alignment: .leading)
        .padding(.top, 100)
        .alert("Category already exist", isPresented: $viewModel.isCategoryDiplicate) {
            Button("OK", role: .cancel) {}
        }
        .onChange(of: viewModel.networkingState) { newValue in
            if newValue == .success {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

struct AddCategoryView_Previews: PreviewProvider {
    static var previews: some View {
        AddCategoryView(viewModel: AddCategoryViewModel(networkingService: NetworkingService()))
    }
}
