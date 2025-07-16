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
                    .styledFont(.bold, size: 15, lineHeight: 24)
            }
            .frame(maxWidth: .infinity)
            .frame(height: channel == .apple ? 60 : 50)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(lineWidth: channel == .google ? 1 : 0)
                    .foregroundStyle(Color.gray100)
                    .background(channel.backgroundColor)
                    .cornerRadius(16, corners: .allCorners)
            )
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
