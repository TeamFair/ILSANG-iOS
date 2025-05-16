//
//  HonorView.swift
//  ILSANG
//
//  Created by Lee Jinhee on 4/26/25.
//

import UIKit

struct Honor {
    let title: String
    let image: UIImage
    let description: String
    
    static let standard = Honor(title: "일반", image: .honorBlue, description: "가장 일반적인 칭호")
    static let rare = Honor(title: "희귀", image: .honorRed, description: "가장 희귀한 칭호")
    static let legend = Honor(title: "전설", image: .honorGold, description: "가장 전설적인 칭호")
}


import SwiftUI

struct HonorIconView: View {
    let honorTitle: String
    let grade: HonorGrade
    let imageSize: CGFloat
    let spacing: CGFloat
    let font: FontStyle
    let fgColor: Color
    
    var body: some View {
        HStack(spacing: spacing) {
            Image(uiImage: grade.image ?? .init())
                .resizable()
                .scaledToFit()
                .frame(imageSize)
            Text(honorTitle)
                .styledFont(font)
                .foregroundStyle(fgColor)
        }
    }
}

#Preview {
    HonorIconView(honorTitle: "세상을 움직이는 자", grade: .standard, imageSize: 18, spacing: 4, font: .badge1, fgColor: .gray400)
}
