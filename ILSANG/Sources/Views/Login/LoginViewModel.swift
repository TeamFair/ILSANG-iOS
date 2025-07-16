//
//  LoginViewModel.swift
//  ILSANG
//
//  Created by Lee Jinhee on 7/11/24.
//

import Foundation
import AuthenticationServices

class LoginViewModel: ObservableObject {
    func googleButtonAction() {
        Task { await UserService.shared.loginWithGoogle() }
        // TODO: 로그인 GA 연결
    }
    
    func loginWithApple(credential: ASAuthorizationCredential) {
        guard let credential = credential as? ASAuthorizationAppleIDCredential else { return }
        
        Task {
            await UserService.shared.login(appleCredential: credential)
            // TODO: 로그인 GA 연결
        }
    }
}
