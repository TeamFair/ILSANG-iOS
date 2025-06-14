//
//  LoginViewModel.swift
//  ILSANG
//
//  Created by Lee Jinhee on 7/11/24.
//

import Foundation
import AuthenticationServices

class LoginViewModel: ObservableObject {
    
    var kakaoButtonAction = {
        //TODO: 로그인 기능 구현
    }
    
    var googleButtonAction = {
        //TODO: 로그인 기능 구현
    }
    
    func loginWithApple(credential: ASAuthorizationCredential) {
        guard let credential = credential as? ASAuthorizationAppleIDCredential else { return }
        
        Task {
            await UserService.shared.login(appleCredential: credential)
            // TODO: 로그인 GA 연결
        }
    }
}
