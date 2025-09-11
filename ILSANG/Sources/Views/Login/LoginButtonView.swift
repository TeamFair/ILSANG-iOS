//
//  LoginButtonView.swift
//  TeamFair
//
//  Created by apple on 2023/07/27.
//

import SwiftUI

struct LoginButtonView: View {
    let channel: LoginButton
    let buttonAction:  () -> ()

    var body: some View {
        Button(action: buttonAction) {
            HStack(spacing: 16) {
                Image(channel.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18)
                Text(channel.labelText)
                    .foregroundColor(channel.accentColor)
                    .styledFont(.medium, size: 14, lineHeight: 20)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .roundedBackground(cornerRadius: 30, bgColor: channel.backgroundColor)
        }
    }
}

#Preview {
    VStack {
        LoginButtonView(channel: .apple, buttonAction: {})
        LoginButtonView(channel: .kakao, buttonAction: {})
        LoginButtonView(channel: .google, buttonAction: {})
    }
}
