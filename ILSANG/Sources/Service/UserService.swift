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
    @AppStorage("accessToken") var accessToken: String = ""
    @AppStorage("refreshToken") var refreshToken: String = ""
    @AppStorage("authChannel") var authChannel = ""
    
    @Published var currentUser: User?
    
    static let shared = UserService()
    
    private init() { }
    
    // MARK: - 로그인
    /// 첫 애플 로그인하는 경우
    // TODO: 애플 로그인 - 백이랑 상의해서 리프레시토큰 받아야함
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
    
    /// 갖고 있는 토큰으로 자동 로그인
    /// do - catch로 logout 호출 필요
    /// 현재 미사용
//    func login() async throws {
//        if authToken.isEmpty {
//            throw LoginError.emptyToken
//        }
//        
//        let authUser = AuthUser(email: userEmail, accessToken: accessToken, refreshToken: refreshToken)
//        dump(authUser)
//        let result = await authService.loginWithChannel(user: authUser, channel: AuthChannel.fromString(value: authChannel)!)
//        
//        switch result {
//        case .success(let user):
//            await updateLoginStatus(true, authToken: user.authToken)
//            completeLogin(with: user.authToken)
//            await fetchUserInfo()
//        case .failure(let err):
//            throw LoginError.loginFailed(err.localizedDescription)
//        }
//    }
    
    /// 새로 발급 받는 토큰으로 로그인하는 경우, 아직사용하지 않음
//    func login(accessToken: String, refreshToken: String, channel: AuthChannel) async {
//        let authUser = AuthUser(email: userEmail, accessToken: accessToken, refreshToken: refreshToken)
//        
//        guard let user = await authService.loginWithChannel(user: authUser, channel: channel) else {
//            // try await logout()
//            return
//        }
//        await completeLogin(with: user.authToken)
//        await fetchUserInfo()
//    }
    
    func logout() async -> Bool {
        if !isLogin { return true }
        let logoutSucc = await authService.logout()
        resetUserSession()
        return logoutSucc
    }
    
    // TODO: REVOKE
    func withdraw() {
        resetUserSession()
    }
    
    private func resetUserSession() {
        isLogin = false
        accessToken = ""
        refreshToken = ""
        currentUser = nil
    }
}

enum LoginError: Error, LocalizedError {
    case emptyToken
    case loginFailed(String)
    case unknown

    var errorDescription: String? {
        switch self {
        case .emptyToken:
            return "토큰이 비어 있습니다."
        case .loginFailed(let result):
            return "로그인에 실패했습니다.\n\(result)"
        case .unknown:
            return "알 수 없는 오류가 발생했습니다."
        }
    }
}
