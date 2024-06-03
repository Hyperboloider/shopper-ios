//
//  AuthView.swift
//  Shopper
//
//  Created by Illia Kniaziev on 18.12.2022.
//

import SwiftUI

struct AuthView: View {
    
    @State private var isSignInActive = true
    @EnvironmentObject var networkingService: NetworkingService
    
    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack {
                    if isSignInActive {
                        SignInView(viewModel: SignInViewModel(networkingService: networkingService))
                    } else {
                        SignUpView(viewModel: SignUpViewModel(networkingService: networkingService))
                    }
                    
                    Spacer()
                    
                    Button(isSignInActive ? "Don't have an account? Sign up!" : "Return to signing in") {
                        isSignInActive.toggle()
                    }
                }
                .animation(.linear, value: isSignInActive)
                .frame(minHeight: proxy.size.height)
            }
        }
    }
}

struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        AuthView()
    }
}
