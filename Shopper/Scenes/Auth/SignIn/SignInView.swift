//
//  SignInView.swift
//  Shopper
//
//  Created by Illia Kniaziev on 18.12.2022.
//

import SwiftUI

struct SignInView: View {
    
    private enum FieldType {
        case email, password
    }
    
    @StateObject var viewModel: SignInViewModel
    @FocusState private var activeField: FieldType?
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(spacing: 20) {
            InputField(focusState: _activeField, text: $viewModel.email, title: "Email", placeholder: "example@email.com", focus: .email) {
                activeField = .password
            }
            .padding(.horizontal)
            
            SecureInputField(focusState: _activeField, text: $viewModel.password, title: "Password", placeholder: "password", focus: .password) {
                if viewModel.canSubmit {
                    viewModel.signIn()
                } else {
                    activeField = .email
                }
            }
            .padding(.horizontal)
        }
        .padding(.horizontal)
        .padding(.vertical, 40)
        
        Button {
            withAnimation {
                viewModel.signIn()
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
        
        .animation(.easeOut(duration: 0.3), value: viewModel.networkingState)
        .onChange(of: viewModel.networkingState) { newValue in
            if case .failure = newValue {
                viewModel.email = ""
                viewModel.password = ""
            }
        }
        .navigationTitle("Sign In")
        .onChange(of: viewModel.user) { newValue in
            if let user = newValue {
                appState.isAdmin = user.isAdmin
                appState.isUserAuthorized = true
                User.save(user)
            }
        }
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SignInView(viewModel: SignInViewModel(networkingService: NetworkingService()))
        }
    }
}
