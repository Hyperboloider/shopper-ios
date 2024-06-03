//
//  SignUpView.swift
//  Shopper
//
//  Created by Illia Kniaziev on 18.12.2022.
//

import SwiftUI

struct SignUpView: View {
    
    private enum FieldType {
        case firstName, lastName, email, password, confirmedPassword
    }
    
    @StateObject var viewModel: SignUpViewModel
    @FocusState private var activeField: FieldType?
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(spacing: 20) {
            InputField(focusState: _activeField, text: $viewModel.firstName, title: "First name", placeholder: "John", focus: .firstName) {
                activeField = .lastName
            }
            .padding(.horizontal)
            
            InputField(focusState: _activeField, text: $viewModel.lastName, title: "Last name", placeholder: "Doe", focus: .lastName) {
                activeField = .email
            }
            .padding(.horizontal)
            
            InputField(focusState: _activeField, text: $viewModel.email, title: "Email", placeholder: "example@email.com", focus: .email) {
                activeField = .password
            }
            .padding(.horizontal)
            
            VStack(spacing: 20) {
                SecureInputField(focusState: _activeField, text: $viewModel.password, title: "Password", placeholder: "password", focus: .password) {
                    activeField = .confirmedPassword
                }
                .padding(.horizontal)
                
                SecureInputField(focusState: _activeField, text: $viewModel.confirmedPassword, title: "Confirm password", placeholder: "confirm password", focus: .confirmedPassword) {
                    if viewModel.canSubmit {
                        viewModel.signUp()
                    } else {
                        activeField = nil
                        activeField = .firstName
                    }
                }
                .padding(.horizontal)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(lineWidth: 2)
                    .foregroundColor(viewModel.doesPasswordsMatch ? .clear : .red)
                    .padding(.horizontal, 8)
            }
            
            SubmitButton(networkingState: $viewModel.networkingState, canSubmit: $viewModel.canSubmit, title: "Submit") {
                withAnimation {
                    viewModel.signUp()
                }
            }
            .disabled(!viewModel.canSubmit)
//            Button {
//                withAnimation {
//                    viewModel.signUp()
//                }
//            } label: {
//                HStack {
//                    Text("Submit")
//                        .font(.system(.title3, weight: .semibold))
//                        .foregroundColor(.white)
//
//                    if case .waiting = viewModel.networkingState {
//                        ProgressView()
//                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
//                            .padding(.leading, 3)
//                    }
//                }
//                .frame(minWidth: 100, maxWidth: 260, minHeight: 42, maxHeight: 42, alignment: .center)
//                .background(viewModel.canSubmit ? Color.green : Color.gray)
//                .cornerRadius(21)
//            }
//            .disabled(!viewModel.canSubmit)
        }
        .padding(.vertical, 40)
        
        .animation(.easeOut(duration: 0.3), value: viewModel.networkingState)
        .onChange(of: viewModel.networkingState) { newValue in
            if case .failure = newValue {
                viewModel.firstName = ""
                viewModel.lastName = ""
                viewModel.email = ""
                viewModel.password = ""
                viewModel.confirmedPassword = ""
            }
        }
        .navigationTitle("Sign Up")
        .onChange(of: viewModel.user) { newValue in
            if let user = newValue {
                appState.isAdmin = user.isAdmin
                appState.isUserAuthorized = true
                User.save(user)
            }
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SignUpView(viewModel: SignUpViewModel(networkingService: NetworkingService()))
        }
    }
}
