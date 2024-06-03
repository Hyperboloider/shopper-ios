//
//  AddProductView.swift
//  Shopper
//
//  Created by Гіяна Князєва on 21.12.2022.
//
import SwiftUI
import PhotosUI

struct AddProductView: View {
    
    private enum FieldType {
        case name, description, upc, price, weight, calories, protein, fat, carb
    }
    
    @StateObject var viewModel: AddProductViewModel
    @Environment(\.presentationMode) private var presentationMode
    @FocusState private var activeField: FieldType?
    
    @State private var photo: PhotosPickerItem?
    
    var body: some View {
        ScrollView {
            VStack {
                VStack {
                    PhotosPicker(selection: $photo, matching: .images, photoLibrary: .shared()) {
                        if let data = viewModel.imageData, let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: .infinity, maxHeight: 200)
                        } else {
                            Label("Add photo", systemImage: "photo")
                        }
                    }
                }
                .padding(.top, 40)
                
                VStack {
                    InputField(focusState: _activeField, text: $viewModel.name, title: "Name", placeholder: "Coke", focus: .name) {
                        activeField = .description
                    }
                    
                    InputField(focusState: _activeField, text: $viewModel.description, title: "Description", placeholder: "Sweet coke we love", focus: .description) {
                        activeField = .upc
                    }
                    
                    ScannerInputField(focusState: _activeField, text: $viewModel.upc, title: "UPC", placeholder: "Barcode info", focus: .upc) {
                        activeField = .price
                    }
                    
                    HStack(alignment: .bottom) {
                        InputField(focusState: _activeField, text: $viewModel.price, title: "Price", placeholder: "9.99", focus: .price) {
                            if viewModel.isPricePerKilo {
                                activeField = .calories
                            } else {
                                activeField = .weight
                            }
                        }
                        
                        Toggle(isOn: $viewModel.isPricePerKilo.animation()) {
                            Text("Per kilo")
                        }
                        .font(.system(.title3, weight: .semibold))
                        .fixedSize()
                        .padding(.bottom, 5)
                    }
                    
                    if !viewModel.isPricePerKilo {
                        InputField(focusState: _activeField, text: $viewModel.weightPerItem, title: "Weight per item(grams)", placeholder: "144", focus: .weight) {
                            activeField = .calories
                        }
                    }
                    
                    InputField(focusState: _activeField, text: $viewModel.calories, title: "Calories per 100 grams", placeholder: "345", focus: .calories) {
                        activeField = .protein
                    }
                    
                    InputField(focusState: _activeField, text: $viewModel.protein, title: "Protein", placeholder: "12", focus: .protein) {
                        activeField = .fat
                    }
                    
                    InputField(focusState: _activeField, text: $viewModel.fat, title: "Fat", placeholder: "7", focus: .fat) {
                        activeField = .carb
                    }
                    
                    InputField(focusState: _activeField, text: $viewModel.carb, title: "Carb", placeholder: "14", focus: .carb) {
                        if viewModel.canSubmit {
                            activeField = nil
                            viewModel.submit()
                        } else {
                            activeField = .name
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Category")
                            .font(.system(.title2, weight: .semibold))
                        
                        TagFilterView(
                            tags: viewModel.categories,
                            placeholder: "Category",
                            isSingleSelection: true,
                            selectedTags: $viewModel.selectedCategories,
                            excludedTags: .constant([]))
                    }
                }
                .padding()
                
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
                    .background(viewModel.canSubmit ? Color.green : Color.gray)
                    .cornerRadius(21)
                }
                .disabled(!viewModel.canSubmit)
            }
        }
        .alert("UPC is already in use", isPresented: $viewModel.isUpcDuplicate) {
            Button("OK", role: .cancel) {}
        }
        .onChange(of: viewModel.networkingState) { newValue in
            if newValue == .success {
                presentationMode.wrappedValue.dismiss()
            }
        }
        .onChange(of: photo) { photo in
            photo?.loadTransferable(type: Data.self) { result in
                if case .success(let data) = result {
                    guard let data else { return }
                    DispatchQueue.global(qos: .userInitiated).async {
                        let uiImage = UIImage(data: data)
                        let jpegData = uiImage?.jpegData(compressionQuality: 0)
                        
                        DispatchQueue.main.async {
                            viewModel.imageData = jpegData
                        }
                    }
                }
            }
        }
    }
}

struct AddProductView_Previews: PreviewProvider {
    static var previews: some View {
        AddProductView(viewModel: AddProductViewModel(networkingService: NetworkingService(), categories: [
            Category(response: CategoryResponse(id: "fuzzy drinks")),
            Category(response: CategoryResponse(id: "fuzzy drinks"))
        ]))
        .environmentObject(PermissonManager())
    }
}
