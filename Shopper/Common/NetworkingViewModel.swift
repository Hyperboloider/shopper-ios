//
//  NetworkingViewModel.swift
//  Shopper
//
//  Created by Illia Kniaziev on 19.12.2022.
//

import Foundation
import Combine

class NetworkingViewModel: ObservableObject {
    
    @Published var networkingState: AuthState = .none
    
    var subscriptions = Set<AnyCancellable>()
    let networkingService: NetworkingServiceProtocol
    
    init(networkingService: NetworkingServiceProtocol) {
        self.networkingService = networkingService
    }
    
    func handleFailure(completion: Subscribers.Completion<Error>) {
        if case .failure(let error) = completion {
            print("Failure: \(error)")
            networkingState = .failure(error)
            HapticsFeedbackGenerator.genereteFeedback(.error)
        }
    }
    
    func handleSuccess<T>(result: T) {
        networkingState = .success
        HapticsFeedbackGenerator.genereteFeedback(.success)
    }
    
}
