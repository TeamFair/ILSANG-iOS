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
        .frame(height: 60)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    AppleLoginButtonView { _ in }
}
