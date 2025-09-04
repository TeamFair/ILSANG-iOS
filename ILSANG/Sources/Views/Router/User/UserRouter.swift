//
//  UserRouter.swift
//  ILSANG
//
//  Created by Lee Jinhee on 9/3/25.
//


import SwiftUI

@MainActor
class UserRouter: ObservableObject {
    @Published var showUserProfile = false
    @Published var selectedUserId: String?
    
    func navigateToUserProfile(userId: String) {
        selectedUserId = userId
        showUserProfile = true
    }
}