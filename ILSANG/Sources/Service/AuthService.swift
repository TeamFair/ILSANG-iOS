//
//  AuthService.swift
//  ILSANG
//
//  Created by Lee Jinhee on 7/10/24.
//

import AuthenticationServices
import Alamofire
import GoogleSignIn
import FirebaseCore

final class AuthService {
    private let authNetwork: AuthNetwork = AuthNetwork()
    
    /// Apple 로그인 흐름을 처리하는 메인 함수
    /// Apple Credential에서 identityToken 추출하여 일상 oAuthLogin API 호출
    func loginWithApple(credential: ASAuthorizationAppleIDCredential) async -> Auth? {
        guard let identityTokenData = credential.identityToken,
              let identityToken = String(data: identityTokenData, encoding: .utf8) else {
            Log("Apple 로그인 실패: identityToken 누락 또는 인코딩 실패")
            return nil
        }
        
        return await performOAuthLogin(channel: .Apple, idToken: identityToken)
    }
    
    /// Google 로그인 흐름을 처리하는 메인 함수
    /// - 이전 로그인 세션이 있으면 복원하고, 없으면 새로 로그인 진행
    func loginWithGoogle() async -> Auth? {
        do {
            // 기존 로그인 복원
            let restoredUser = try await GIDSignIn.sharedInstance.restorePreviousSignIn()
            Log(restoredUser)
            guard let _ = restoredUser.profile else { throw GIDSignInError(.unknown) } // profile이 없으면 복원 실패로 처리
            return await handleGoogleLogin(for: restoredUser) // 복원 성공 → 인증 처리
        } catch {
            // 신규 로그인 시도
            Log("Google 로그인 세션 복원 실패. 신규 로그인 시도 예정: \(error.localizedDescription)")
            return try? await startGoogleSignInFlow() // 복원 실패 → 새 로그인 시도
        }
    }
    
    /// Google 로그인 UI 흐름을 시작하고, 로그인 결과로 토큰 요청
    @MainActor private func startGoogleSignInFlow() async throws -> Auth? {
        guard let presentingVC = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController else {
            return nil
        }
        
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            return nil
        }

        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        // 로그인 UI 표시 및 사용자 인증 요청
        let signInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: presentingVC)
        guard let _ = signInResult.user.profile else {
            Log("Google 로그인 실패: 프로필이 없습니다.")
            throw GIDSignInError(.unknown)
        }
        // 로그인 성공 → 인증 처리
        return await handleGoogleLogin(for: signInResult.user)
    }
    
    /// 로그인된 Google 사용자 정보로 서버에 로그인 요청
    /// - 서버에 idToken을 보내서 자체 로그인 처리
    private func handleGoogleLogin(for user: GIDGoogleUser) async -> Auth? {
        guard let idToken = user.idToken?.tokenString else {
            Log("Google 로그인 실패: ID Token이 없습니다.")
            return nil
        }
        return await performOAuthLogin(channel: .Google, idToken: idToken)
    }
    
    /// 공통된 OAuth 로그인 처리
    private func performOAuthLogin(
        channel: AuthChannel,
        idToken: String
    ) async -> Auth? {
        let result = await authNetwork.login(idToken: idToken, channel: channel)
        switch result {
        case .success(let token):
            Log("\(channel.stringValue) 로그인 성공: \(token)")
            return Auth(accessToken: token.accessToken, refreshToken: token.refreshToken)
        case .failure(let error):
            Log("\(channel.stringValue) 로그인 실패: \(error.localizedDescription)")
            return nil
        }
    }
    
    func logout() async -> Bool {
        switch await authNetwork.logout() {
        case .success:
            return true
        case .failure:
            return false
        }
    }
    
    func refresh(accessToken: String, refreshToken: String) async -> Auth? {
        let refreshResult = await authNetwork.refresh(accessToken: accessToken, refreshToken: refreshToken)
        switch refreshResult {
        case .success(let auth):
            return auth
        case .failure:
            return nil
        }
    }
}

struct Auth: Codable {
    let accessToken: String
    let refreshToken: String
}
