//
//  SignInViewModel.swift
//  Shopper
//
//  Created by Illia Kniaziev on 18.12.2022.
//

import Foundation
import Combine

final class SignInViewModel: AuthViewModel {
    @Published var email = ""
    @Published var password = ""
    
    override init(networkingService: NetworkingServiceProtocol) {
        super.init(networkingService: networkingService)
        subscribeOnInput()
    }
    
    func signIn() {
        guard
            networkingState != .waiting,
            let email = Email(email: email),
            let password = Password(password: password)
        else { return }
        
        networkingState = .waiting
        handleAuthResponse(
            fromPublisher: SignInRequest(email: email, password: password)
                .perform(byService: networkingService)
        )
    }
}

// MARK: - Validation
private extension SignInViewModel {
    func subscribeOnInput() {
        Publishers
            .CombineLatest($email, $password)
            .sink { [weak self] inEmail, inPassword in
                guard
                    Validator.validate(string: inEmail, usingPattern: .email),
                    !inPassword.isEmpty
                else {
                    self?.canSubmit = false
                    return
                }
                
                self?.canSubmit = true
            }
            .store(in: &subscriptions)
    }
}
