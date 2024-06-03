//
//  EventSchemas.swift
//  Shopper
//
//  Created by Illia Kniaziev on 25.04.2024.
//

import Foundation

struct UserSchema: MirrorSocketData {
    let userId: String
    let userName: String
    let socketId: String
}

struct UpdateListSchema: MirrorSocketData {
    let eventName: ServerToClientEventType
    let senderId: String
    let shoppingListId: String
}

struct JoinShoppingListSchema: MirrorSocketData {
    let eventName: ClientToServerEventType
    let user: UserSchema
}
