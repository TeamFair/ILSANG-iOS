//
//  ProgressBar.swift
//  ILSANG
//
//  Created by Lee Jinhee on 3/8/25.
//

import SwiftUI

struct ProgressBar: View {
    let progress: Double
    var height: CGFloat = 8
    
    var body: some View {
        ZStack(alignment: .leading) {
            Rectangle()
                .frame(height: height)
                .cornerRadius(6)
                .foregroundColor(.gray100)
            
            Rectangle()
                .frame(height: height)
                .cornerRadius(6)
                .foregroundColor(.accent)
                .scaleEffect(x: min(max(progress, 0), 1), anchor: .leading) // 0~1 범위로 제한
        }
    }
}

struct ProgressCircleView: View {
    let progress: Double // 0.0 ~ 1.0
    let size: CGSize
    private var calProgress: Double {
        let result = progress / 10 * 7.45
        return floor(result * 100) / 100
    }
    private let startRotationDegrees = 136.0
    private let lineWidth: CGFloat = 9
    private var circleInset: CGFloat { lineWidth / 2 }
    
    var body: some View {
        ZStack {
            Circle()
                .inset(by: circleInset)
                .stroke(lineWidth: lineWidth)
                .foregroundColor(.gray100.opacity(0.85))
            
            Circle()
                .inset(by: circleInset)
                .trim(from: 0.0, to: calProgress)
                .stroke(
                    .primary500,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round)
                )
                .rotationEffect(.degrees(startRotationDegrees))
                .animation(.easeOut(duration: 0.5), value: calProgress)
        }
        .frame(size)
        .background(.clear)
    }
}

fileprivate struct ProgressCirclePreview: View {
    @State private var progress = 0.15
    
    var body: some View {
        VStack {
            ProgressCircleView(progress: progress, size: .init(width: 100, height: 100))
                .padding()
            
            // 테스트용 슬라이더
            Slider(value: $progress)
                .padding()
        }
    }
}
#Preview {
    VStack {
        ProgressBar(progress: 0.88)        
        ProgressCirclePreview()
    }
}
