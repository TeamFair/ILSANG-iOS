//
//  LoginButton.swift
//  TeamFair
//
//  Created by apple on 2023/07/27.
//

import Foundation
import SwiftUI

enum LoginButton {
    case kakao
    case google
    case apple
    
    var imageName: String {
        switch self {
        case .kakao:
            return "KakaoLogo"
        case .google:
            return "GoogleLogo"
        case .apple:
            return "AppleLogo"
        }
    }
    
    var labelText: String {
        switch self {
        case .kakao:
            return "카카오로 로그인하기"
        case .google:
            return "Google로 로그인하기"
        case .apple:
            return "Apple로 로그인하기"
        }
    }
    
    var accentColor: Color {
        switch self {
        case .kakao:
            return .KakaoAccentColor
        case .google:
            return .GoogleAccentColor
        case .apple:
            return .AppleAccentColor
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .kakao:
            return .KakakoBackground
        case .google:
            return .GoogleBackground
        case .apple:
            return .AppleBackground
        }
    }
}
