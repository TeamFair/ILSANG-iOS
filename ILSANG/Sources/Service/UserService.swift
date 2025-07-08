//
//  UserService.swift
//  ILSANG
//
//  Created by Lee Jinhee on 7/10/24.
//

import SwiftUI
import AuthenticationServices

final class UserService: ObservableObject {
    let userNetwork: UserNetwork = UserNetwork()
    let authService: AuthService = AuthService()
    
    @AppStorage("isLogin") var isLogin = Bool()
    @AppStorage("accessToken") var accessToken: String = "eyJhbGciOiJIUzI1NiJ9.eyJ1c2VySWQiOiIxMDJhM2MwNC1jZTJlLTQ2ZTEtOGZmOC05ZTk5YTZiYjZhMWUiLCJ1c2VyVHlwZSI6IkNVU1RPTUVSIiwic2FsdCI6Nzk1fQ.a00LDp9nDnyUpzApojBdybDOqX0h1Ms18yevc_tPuJI"
    @AppStorage("refreshToken") var refreshToken: String = ""
    @AppStorage("authChannel") var authChannel = ""
    
    @Published var currentUser: User?
    
    static let shared = UserService()
    
    private init() { }
    
    // MARK: - 로그인
    /// 첫 애플 로그인하는 경우
    func login(appleCredential: ASAuthorizationAppleIDCredential) async {
        guard let authResult = await authService.loginWithApple(credential: appleCredential) else { return }
        await handleLoginSuccess(authResult: authResult, channel: .Apple)
    }
    
    /// 구글 로그인하는 경우
    func loginWithGoogle() async {
        guard let authResult = await authService.loginWithGoogle() else { return }
        await handleLoginSuccess(authResult: authResult, channel: .Google)
    }
    
    @MainActor
    private func handleLoginSuccess(authResult: Auth, channel: AuthChannel) async {
        self.accessToken = authResult.authorization
        self.refreshToken = authResult.refreshToken
        self.authChannel = channel.stringValue

        await fetchUserInfo()
        if self.currentUser != nil {
            self.isLogin = true
        }
    }
    
    @MainActor
    func fetchUserInfo() async {
        let userInfo = await userNetwork.getUser()
        switch userInfo {
        case .success(let res):
            self.currentUser = res.data
        case .failure:
            self.currentUser = nil
        }
    }
    
    func logout() async -> Bool {
        if !isLogin { return true }
        let logoutSucc = await authService.logout()
        resetUserSession()
        return logoutSucc
    }
    
    func withdraw() {
        // TODO: REVOKE
        resetUserSession()
    }
    
    private func resetUserSession() {
        isLogin = false
        accessToken = ""
        refreshToken = ""
        currentUser = nil
    }
    
    func updateToken(accessToken: String, refreshToken: String) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }
}
