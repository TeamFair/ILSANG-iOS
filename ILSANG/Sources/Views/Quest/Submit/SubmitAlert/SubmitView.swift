//
//  SubmitView.swift
//  ILSANG
//
//  Created by Lee Jinhee on 3/6/25.
//

import SwiftUI

struct SubmitView: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            HStack(spacing: 6) {
                ForEach(0..<3, id: \.self) { idx in
                    Circle()
                        .fill(IconColor.blue.fgColor)
                        .frame(width: 8, height: 8)
                        .opacity(animate ? 1 : 0.5)
                        .offset(y: animate ? -4 : 2) // 위아래 애니메이션
                        .animation(
                            Animation.easeInOut(duration: 0.6)
                                .repeatForever()
                                .delay(Double(idx) * 0.2), // 각 원이 순차적으로 애니메이션
                            value: animate
                        )
                }
            }
        }
        .frame(width: 60, height: 60)
        .background(Circle().fill(IconColor.blue.bgColor))
        .onAppear {
            animate.toggle()
        }
    }
}

#Preview {
    SubmitView()
}
