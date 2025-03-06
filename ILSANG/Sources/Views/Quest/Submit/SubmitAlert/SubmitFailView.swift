//
//  SubmitFailView.swift
//  ILSANG
//
//  Created by Lee Jinhee on 3/6/25.
//

import SwiftUI

struct SubmitFailView: View {
    @State private var animate = false
    
    var body: some View {
        Image(.xmark)
            .foregroundStyle(IconColor.red.fgColor)
            .frame(width: 8, height: 8)
            .scaleEffect(animate ? 1: 0.9)
            .opacity(animate ? 1 : 0.6)
            .rotationEffect(animate ? .degrees(-2) : .degrees(2))
            .animation(
                Animation.easeInOut(duration: 0.7).repeatForever(),
                value: animate
            )
            .frame(width: 60, height: 60)
            .background(
                Circle().fill(IconColor.red.bgColor)
            )
            .onAppear {
                animate.toggle()
            }
    }
}

#Preview {
    SubmitFailView()
}
