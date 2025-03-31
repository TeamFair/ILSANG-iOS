//
//  View++.swift
//  ILSANG
//
//  Created by Lee Jinhee on 5/29/24.
//

import SwiftUI
import CryptoKit

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
    
    @ViewBuilder
    func frame(_ size: CGSize) -> some View {
        self.frame(width: size.width, height: size.height)
    }
    
    @ViewBuilder
    func cropImagePicker(show: Binding<Bool>, croppedImage: Binding<UIImage?>) -> some View {
        CustomImagePicker(show: show, croppedImage: croppedImage) {
            self
        }
    }
    
    func haptics(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

extension View {
    func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError(
                        "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
                    )
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        return result
    }
    
    func styledFont(_ fontWeight: UIFont.Weight, size: CGFloat, lineHeight: CGFloat, tracking: CGFloat = 0) -> some View {
        return ModifiedContent(
            content: self,
            modifier: FontWithLineHeight(
                font: Font.uiFont(fontWeight, size),
                lineHeight: lineHeight,
                tracking: tracking
            )
        )
    }
    
    func styledFont(_ fontStyle: FontStyle) -> some View {
        return ModifiedContent(
            content: self,
            modifier: FontWithLineHeight(
                font: Font.uiFont(fontStyle.weight, fontStyle.size),
                lineHeight: fontStyle.lineHeight,
                tracking: fontStyle.tracking
            )
        )
    }

    func roundedBackground(cornerRadius: CGFloat, bgColor: Color = .white) -> some View {
        return ModifiedContent(
            content: self,
            modifier: RoundedBackground(
                cornerRadius: cornerRadius,
                backgroundColor: bgColor
            )
        )
    }
    
    // 키보드밖 화면 터치시 키보드 사라짐 .onTapGesture에서 사용
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
