//
//  AuthService.swift
//  ILSANG
//
//  Created by Lee Jinhee on 7/10/24.
//

import AuthenticationServices

class AuthService {
    let authNetwork: AuthNetwork = AuthNetwork()
    
    /// Apple Credential에서 identityToken 추출하여 일상 oAuthLogin API 호출
    func loginWithApple(credential: ASAuthorizationAppleIDCredential) async -> AuthResponse? {
        guard let identityToken = credential.identityToken else {
            Log("ERROR WITH IDENTITYTOKEN")
            return nil
        }
        
        guard let identityTokenString = String(data: identityToken, encoding: .utf8) else {
            Log("ERROR WITH TOKEN ENCODING")
            return nil
        }
        
        let result = await authNetwork.login(idToken: identityTokenString, channel: .Apple)
        
        switch result {
        case .success(let authToken):
            // TODO: BE 로직 추가 시 refreshToken 관련 확인 필요
            // TODO: 현재 AccessToken에 idToken 임의 저장 >> 구글로그인 구현 및 BE 로직 개선 시 수정 필요
            return AuthResponse(
                authToken: authToken,
                authUser: AuthUser(accessToken: identityTokenString, refreshToken: "")
            )
        case .failure(let error):
            Log(error.localizedDescription)
            return nil
        }
    }
    
    /// AuthChannel에 따라  자동로그인 시 사용
    // TODO: 구글 및 자동 로그인 구현 시 로직 재점검 필요
//    func loginWithChannel(user: AuthUser, channel: AuthChannel) async -> Result<AuthResponse, Error> {
//        let idToken = UserService.shared.accessToken
//        let result = await authNetwork.login(idToken: idToken, channel: channel)
//        
//        switch result {
//        case .success(let authToken):
//            return .success(AuthResponse(authToken: authToken, authUser: user))
//        case .failure(let error):
//            Log(error.localizedDescription)
//            return .failure(error)
//        }
//    }
}

struct AwsAuth: Codable {
    let authorization: String
}
