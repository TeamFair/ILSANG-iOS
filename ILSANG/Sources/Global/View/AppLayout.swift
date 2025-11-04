//
//  AppLaayout.swift
//  ILSANG
//
//  Created by Lee Jinhee on 11/4/25.
//

import SwiftUI

/// 레이아웃 관련 정보를 담는 구조체
struct LayoutInfo {
    let horizontalPadding: CGFloat
    let bottomSpacing: CGFloat
    let buttonBottomPadding: CGFloat
}

/// 화면 크기에 따라 레이아웃 값을 계산
extension LayoutInfo {
    static func forSize(_ size: CGSize) -> LayoutInfo {
        switch size.width {
        case 0...375: // iPhone SE
            return LayoutInfo(
                horizontalPadding: 16,
                bottomSpacing: 36,
                buttonBottomPadding: 8
            )
        case 376..<430: // 일반 iPhone
            return LayoutInfo(
                horizontalPadding: 20,
                bottomSpacing: 72,
                buttonBottomPadding: 4
            )
        case 430..<600: // Pro Max 등
            return LayoutInfo(
                horizontalPadding: 20,
                bottomSpacing: 72,
                buttonBottomPadding: 4
            )
        default: // iPad
            return LayoutInfo(
                horizontalPadding: 24,
                bottomSpacing: 48,
                buttonBottomPadding: 4
            )
        }
    }
}

/// EnvironmentKey 정의
private struct LayoutKey: EnvironmentKey {
    static let defaultValue = LayoutInfo(
        horizontalPadding: 20,
        bottomSpacing: 72,
        buttonBottomPadding: 0
    )
}

extension EnvironmentValues {
    var layout: LayoutInfo {
        get { self[LayoutKey.self] }
        set { self[LayoutKey.self] = newValue }
    }
}
