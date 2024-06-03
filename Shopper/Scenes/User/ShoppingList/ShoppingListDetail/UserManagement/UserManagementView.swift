//
//  UserManagementView.swift
//  Shopper
//
//  Created by Illia Kniaziev on 12.05.2024.
//

import SwiftUI
import Combine

struct UserManagementView: View {
    
    @StateObject var viewModel: UserManagementViewModel
    
    var body: some View {
        WaitingView(
            refetchAction: viewModel.fetchUsers,
            networkStatePublisher: viewModel.$networkingState.eraseToAnyPublisher()
        ) {
            VStack {
                List {
                    ForEach(viewModel.users) { user in
                        VStack(spacing: 12) {
                            Text(user.fullName)
                            
                            Text(addAsteriskMask(forString: user.id))
                                .foregroundStyle(Color.gray)
                                .font(.caption)
                        }
                    }
                    .onDelete(perform: viewModel.handleRemoval)
                }
            }
        }
        .onAppear {
            viewModel.fetchUsers()
        }
    }
    
    func addAsteriskMask(forString string: String) -> String {
        let midIndex = string.count / 3 * 2
        guard
            let midStringIndex = string.index(string.startIndex, offsetBy: midIndex, limitedBy: string.endIndex)
        else { return "****" }
        return String(repeating: "*", count: midIndex) + string[midStringIndex...]
    }
}

#Preview {
    UserManagementView(viewModel: .init(networkingService: NetworkingService(), listId: "", userIds: []))
}
