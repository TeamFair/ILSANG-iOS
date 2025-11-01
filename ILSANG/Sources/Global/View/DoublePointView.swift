//
//  DoublePointView.swift
//  ILLSANG
//
//  Created by Lee Jinhee on 10/27/25.
//

import SwiftUI

struct DoublePointView: View {
    enum Style {
        case text
        case background
        
        var gradient: LinearGradient {
            LinearGradient(
                colors: [.doublePointLeft, .doublePointRight],
                startPoint: .leading,
                endPoint: .trailing
            )
        }
    }
    let style: Style
    
    var body: some View {
        Text("X2")
            .styledFont(.badge2)
            .frame(width: 20, height: 20)
            .foregroundStyle(
                style == .text
                ? AnyShapeStyle(style.gradient)
                : AnyShapeStyle(Color.white)
            )
            .background(
                style == .background
                ? style.gradient.clipShape(Circle())
                : nil
            )
    }
}

#Preview {
    DoublePointView(style: .text)
    DoublePointView(style: .background)
}
