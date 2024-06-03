//
//  AdminMenuView.swift
//  Shopper
//
//  Created by Гіяна Князєва on 21.12.2022.
//

import SwiftUI
import RealmSwift

struct AdminMenuView: View {
    
    @ObservedResults(User.self) private var users
    @EnvironmentObject private var networkingService: NetworkingService
    
    var body: some View {
        TabView {
            ContentPanelView()
                .tabItem {
                    Label("Content panel", systemImage: "list.clipboard")
                }
            
            if let user = users.first {
                ProfileView(user: user)
                    .tabItem {
                        Label("Profile", systemImage: "person.crop.circle")
                    }
            }
        }
    }
}

struct AdminMenuView_Previews: PreviewProvider {
    static var previews: some View {
        AdminMenuView()
    }
}
