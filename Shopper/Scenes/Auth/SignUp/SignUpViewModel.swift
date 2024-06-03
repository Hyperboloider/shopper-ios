//
//  SignUpViewModel.swift
//  Shopper
//
//  Created by Illia Kniaziev on 18.12.2022.
//

import Foundation
import Combine

final class SignUpViewModel: AuthViewModel {
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var email = ""
    @Published var password = ""
    @Published var confirmedPassword = ""
    @Published var doesPasswordsMatch = true
    
    override init(networkingService: NetworkingServiceProtocol) {
        super.init(networkingService: networkingService)
        watchPasswordsMatch()
        subscribeOnInput()
    }
    
    func signUp() {
        guard
            networkingState != .waiting,
            let email = Email(email: email),
            let password = Password(password: password),
            !firstName.isEmpty,
            !lastName.isEmpty
        else { return }
        
        networkingState = .waiting
        handleAuthResponse(
            fromPublisher: SignUpRequest(firstName: firstName, lastName: lastName, email: email, password: password)
                .perform(byService: networkingService)
        )
    }
    
}

// MARK: - Validation
private extension SignUpViewModel {
    func subscribeOnInput() {
        Publishers
            .CombineLatest4($firstName, $lastName, $email, Publishers.CombineLatest($password, $confirmedPassword))
            .sink { [weak self] (firstName, lastName, email, passwords) in
                let (password, confirmedPassword) = passwords
                
                guard
                    Validator.validate(string: email, usingPattern: .email),
                    Validator.validate(string: password, usingPattern: .password),
                    !firstName.isEmpty,
                    !lastName.isEmpty,
                    password == confirmedPassword
                else {
                    self?.canSubmit = false
                    return
                }
                
                self?.canSubmit = true
            }
            .store(in: &subscriptions)
    }
    
    func watchPasswordsMatch() {
        Publishers
            .CombineLatest($password, $confirmedPassword)
            .sink { [weak self] password, confirmedPassword in
                self?.doesPasswordsMatch = password == confirmedPassword
            }
            .store(in: &subscriptions)
    }
}
