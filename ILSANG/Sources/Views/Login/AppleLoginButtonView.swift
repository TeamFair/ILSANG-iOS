//
//  AppleLoginButtonView.swift
//  TeamFair
//
//  Created by apple on 2023/07/27.
//

import SwiftUI
import AuthenticationServices

struct AppleLoginButtonView: View {
    let onLoginSuccess: (ASAuthorizationCredential) -> ()

    var body: some View {
        SignInWithAppleButton { request in
            request.requestedScopes = [.email]
            request.nonce = sha256(randomNonceString())
        } onCompletion: { result in
            switch result {
            case .success(let authResult):
                onLoginSuccess(authResult.credential)
            case .failure(let error):
                Log(error.localizedDescription)
            }
        }
        .frame(width: 183, height: 44)
        .clipShape(RoundedRectangle(cornerRadius: 30))
    }
}

#Preview {
    AppleLoginButtonView { _ in }
}
