//
//  ProfileView.swift
//  Shopper
//
//  Created by Гіяна Князєва on 20.12.2022.
//

import SwiftUI

struct ProfileView: View {
    
    let user: User
    
    @EnvironmentObject private var networkingService: NetworkingService
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    VStack(alignment: .leading) {
                        Text("\(user.firstName) \(user.lastName)")
                            .font(.system(.title2))
                        
                        Text(Array(user.roles).map({ $0.rawValue }).joined(separator: ", "))
                            .font(.system(.caption))
                            .foregroundColor(.secondary)
                    }
                    
                    Button {
                        NotificationCenter.default.post(Notification(name: .logOutNotification))
                    } label: {
                        Label("Log out", systemImage: "door.left.hand.open")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .foregroundColor(.primary)
                    .buttonStyle(.borderless)
                }
                
                if !user.isAdmin {
                    Section {
                        NavigationLink {
                            ProfileCodeView(viewModel: ProfileCodeViewModel(string: user.id))
                        } label: {
                            Label("My profile code", systemImage: "barcode")
                        }
                        
                        NavigationLink {
                            OrdersView(viewModel: OrdersViewModel(networkingService: networkingService, initialUserId: user.id))
                        } label: {
                            Label("History", systemImage: "clock")
                        }
                    }
                    .foregroundColor(.primary)
                }
            }
        }
    }
    
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(user: User(response: UserResponse(id: "sdsd", firstName: "Illia", lastName: "Kniaziev", email: "ksdksdj@gmail.com", roles: [.user])))
            .environmentObject(NetworkingService())
    }
}
