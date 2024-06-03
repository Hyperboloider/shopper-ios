//
//  NetworkingViewModel.swift
//  Shopper
//
//  Created by Illia Kniaziev on 19.12.2022.
//

import Foundation
import Combine

class NetworkingViewModel: ObservableObject {
    
    @Published var networkingState: NetworkState = .none
    
    var subscriptions = Set<AnyCancellable>()
    let networkingService: NetworkingServiceProtocol
    
    init(networkingService: NetworkingServiceProtocol) {
        self.networkingService = networkingService
    }
    
    func handleCompletion(_ completion: Subscribers.Completion<Error>) {
        DispatchQueue.main.async { [self] in
            switch completion {
            case .finished:
                print("Success")
                networkingState = .success
            case .failure(let error):
                print("Failure: \(error)")
                HapticsFeedbackGenerator.genereteFeedback(.error)
                networkingState = .failure(error)
            }
        }
    }
    
    func getStatusCodeIfPossible(from completion: Subscribers.Completion<Error>) -> Int? {
        if case .failure(let error) = completion {
            if let error = error as? NetworkingService.NetworkingError, case .unacceptableStatusCode(let statusCode, _) = error {
                return statusCode
            }
        }
        
        return nil
    }
    
}
