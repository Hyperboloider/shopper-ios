//
//  AuthViewModel.swift
//  Shopper
//
//  Created by Illia Kniaziev on 18.12.2022.
//

import Foundation
import Combine

class AuthViewModel: NetworkingViewModel {
    @Published var canSubmit = false
    @Published var user: UserResponse?
    
    func handleAuthResponse(fromPublisher publisher: AnyPublisher<AuthResponse, Error>) {
        publisher
            .tryMap(Authenticator.transformAuthResponse)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: handleCompletion) { [weak self] jwt in
                print("🟢 Ok: \(jwt)")
                self?.fetchProfile()
            }
            .store(in: &subscriptions)
    }
    
    private func fetchProfile() {
        ProfileRequest()
            .perform(byService: networkingService)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: handleCompletion) { [weak self] user in
                print("🟢 user: \(user) isAdmin: \(user.isAdmin)")
                self?.user = user
                self?.networkingState = .success
            }
            .store(in: &subscriptions)
    }
}
