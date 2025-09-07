//
//  UserNavigationSetup.swift
//  ILSANG
//
//  Created by Lee Jinhee on 9/3/25.
//


import SwiftUI

extension View {
    func withUserNavigation(userRouter: UserRouter) -> some View {
        self.modifier(UserNavigationSetup(userRouter: userRouter))
    }
}

struct UserNavigationSetup: ViewModifier {
    @ObservedObject var userRouter: UserRouter
    @EnvironmentObject var dependencies: AppDependencies
    
    func body(content: Content) -> some View {
        content
            .navigationDestination(isPresented: $userRouter.showUserProfile) {
                if let userId = userRouter.selectedUserId {
                    OtherUserProfileView(
                        userId: userId,
                        userRepository: dependencies.userRepository,
                        missionHistoryRepository: dependencies.missionHistoryRepository,
                        areaNameService: dependencies.areaNameService,
                        seasonManager: dependencies.seasonManager
                    )
                    .environmentObject(dependencies)
                }
            }
    }
}
