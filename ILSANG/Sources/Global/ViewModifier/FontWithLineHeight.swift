//
//  FontWithLineHeight.swift
//  ILSANG
//
//  Created by Lee Jinhee on 2/10/25.
//

import SwiftUI

struct FontWithLineHeight: ViewModifier {
    let font: UIFont
    let lineHeight: CGFloat // Text의 전체 높이 (Full Height)
    let tracking: CGFloat

    func body(content: Content) -> some View {
        content
            .font(Font(font))
            .tracking(tracking)
            .lineSpacing(lineHeight - font.lineHeight)
            .padding(.vertical, (lineHeight - font.lineHeight) / 2)
    }
}
