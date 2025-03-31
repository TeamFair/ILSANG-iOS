//
//  RoundedBackground.swift
//  ILSANG
//
//  Created by Lee Jinhee on 2/13/25.
//

import SwiftUI

struct RoundedBackground: ViewModifier {
    let cornerRadius: CGFloat
    let backgroundColor: Color
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(backgroundColor)
            )
    }
}
