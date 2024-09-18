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
    
    @AppStorage("authToken") var authToken: String = ""
    @AppStorage("accessToken") var accessToken: String = ""
    @AppStorage("refreshToken") var refreshToken: String = ""
    @AppStorage("userEmail") var userEmail: String = ""
    @AppStorage("authChannel") var authChannel = ""
    
    /// Apple Login은 1번만 emai을 제공하기 때문에 따로 관리
    @AppStorage("appleEmail") var appleEmail: String = ""
    
    @Published var currentUser: User?
    
    static var shared = UserService()
    
    private init() { }
    
    // MARK: - 로그인
    /// 첫 애플 로그인하는 경우
    @MainActor
    func login(appleCredential: ASAuthorizationAppleIDCredential) async {
        guard let authResult = await authService.loginWithApple(credential: appleCredential, storedEmail: appleEmail) else {
            return
        }
        
        // TODO: 애플 로그인 - 백이랑 상의해서 리프레시토큰 받아야함
        self.authToken = authResult.authToken
        self.authChannel = AuthChannel.Apple.stringValue
        
        if authResult.authUser.email != "" {
            self.appleEmail = authResult.authUser.email
            self.userEmail = authResult.authUser.email
        }
        
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
    
    /// 갖고 있는 토큰으로 로그인 시도
    func login() async throws -> Bool {
        let authUser = AuthUser(email: userEmail, accessToken: accessToken, refreshToken: refreshToken)
        if authToken.isEmpty {
            await updateLoginStatus(false)
            return false
        }
        guard let user = await authService.loginWithChannel(user: authUser, channel: AuthChannel.fromString(value: authChannel)!) else {
            // try await logout()
            return false
        }
        await updateLoginStatus(true, authToken: user.authToken)
        await fetchUserInfo()
        return true
    }
    
    /// 새로 발급 받는 토큰으로 로그인하는 경우, 아직사용하지 않음
    func login(accessToken: String, refreshToken: String, channel: AuthChannel) async throws {
        let authUser = AuthUser(email: userEmail, accessToken: accessToken, refreshToken: refreshToken)
        
        guard let user = await authService.loginWithChannel(user: authUser, channel: channel) else {
            // try await logout()
            await updateLoginStatus(false)
            return
        }
        await updateLoginStatus(true, authToken: user.authToken)
        await fetchUserInfo()
    }
    
    @MainActor
    func logout() {
        // TODO: 로그아웃 로직 추가 확인 필요
        updateLoginStatus(false, authToken: "")
    }
    
    @MainActor
    func withdraw() {
        // TODO: 회원탈퇴 로직 추가 확인 필요
        updateLoginStatus(false, authToken: "")
    }
    
    @MainActor
    private func updateLoginStatus(_ isLogin: Bool, authToken: String) {
        if self.isLogin != isLogin {
            self.isLogin = isLogin
        }
        self.authToken = authToken
    }
    
    @MainActor
    private func updateLoginStatus(_ isLogin: Bool) {
        if self.isLogin != isLogin {
            self.isLogin = isLogin
        }
    }
    
    #if DEBUG
    func loginWithTest() async {
        guard let res = await authService.loginWithTest(email: "text@naver.com") else { return }
        self.authToken = res.authToken
        self.userEmail = "text@naver.com"
        self.authChannel = AuthChannel.Apple.stringValue
        await fetchUserInfo()
        self.isLogin = true
    }
    #endif
}
