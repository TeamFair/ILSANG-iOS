//
//  SubmitCompleteView.swift
//  ILSANG
//
//  Created by Lee Jinhee on 3/6/25.
//

import SwiftUI

/// 제출 완료 상태 화면
struct SubmitCompleteView: View {
    let totalXP: Int
    let xpStats: [XpStat: Int]
    let action: () -> ()
    
    private let defaultSpacing: CGFloat = 16
    
    @StateObject private var viewModel = EffectViewModel()
    
    @State var animateToggle: Bool = false
    @State var animateToggleOpacity: Bool = false
    @State var animateToggle2: Bool = false
    
    init(quest: QuestViewModelItem, action: @escaping ()->()) {
        self.totalXP = quest.totalRewardXP()
        self.xpStats  = quest.rewardDic
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: defaultSpacing) {
            arrowEffectView
            
            Text("\(totalXP)XP가 상승했어요")
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(.gray500)
            
            xpStatSummaryView(statValues: xpStats)
            
            PrimaryButton(title: "확인") {
                action()
            }
        }
        .padding(defaultSpacing)
        .frame(width: 260)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .foregroundStyle(.white)
        )
        .onAppear {
            startEffectAnimation()
            
            withAnimation(.easeInOut(duration: 0.7).repeatForever(autoreverses: true)) {
                animateToggle2.toggle()
            }
        }
    }
    
    private func startEffectAnimation() {
        Timer.scheduledTimer(withTimeInterval: 1.4, repeats: true) { _ in
            animateToggleOpacity = false
            animateToggle = false
            
            withAnimation(.easeOut(duration: 0.7)) {
                animateToggleOpacity = true
                animateToggle = true
            }
            
            // 새로운 효과를 생성하여 뷰 업데이트
            DispatchQueue.main.async {
                self.viewModel.generateRandomEffects()
            }
        }
    }
    
    private var arrowEffectView: some View {
        ZStack {
            Image(.arrowUpGreen)
                .frame(alignment: .bottom)
                .scaleEffect(animateToggle2 ? 1.3 : 0.9)
                .offset(y: animateToggle2 ? -6 : 2)
                .offset(y: 2)
            
            // 고정 4개
            //            ForEach(viewModel.staticEffects, id: \.id) { effect in
            //                staticRectangle(x: effect.position.0, y: effect.position.1, randomSize: effect.size, offset: effect.offset, cornerRadius: effect.cornerRadius, color: effect.color)
            //            }
            
            
            // 랜덤 5개
            ZStack(alignment: .bottom) {
                ForEach(viewModel.effects, id: \.id) { effect in
                    scaleEffectRectangle(x: effect.position.0, y: effect.position.1, randomSize: effect.size, offset: effect.offset, cornerRadius: effect.cornerRadius, color: effect.color)
                }
            }
            .frame(alignment: .bottom)
            .opacity(animateToggleOpacity ? 1 : 0.0)
            .offset(y: animateToggle ? -4 : 2.0)
            .scaleEffect(animateToggle ? 1.1 : 0.65)
        }
        .frame(width:58, height: 45)
        .padding(.bottom, -8)
    }
    
    private func staticRectangle(x: CGFloat, y: CGFloat, randomSize: CGFloat, offset: CGFloat, cornerRadius: CGFloat, color: Color) -> some View {
        Rectangle()
            .fill(color)
            .frame(width: randomSize, height: randomSize)
            .cornerRadius(cornerRadius)
            .offset(x: x + offset, y: y+offset)
            .offset(y: animateToggle2 ? offset : 0.0)
            .opacity(animateToggle2 ? randomSize/15 : 0.6)
            .scaleEffect(0.8)
    }
    
    private func scaleEffectRectangle(x: CGFloat, y: CGFloat, randomSize: CGFloat, offset: CGFloat, cornerRadius: CGFloat, color: Color) -> some View {
        Rectangle()
            .fill(color)
            .frame(width: randomSize, height: randomSize)
            .cornerRadius(cornerRadius)
            .offset(x: x + offset, y: y + offset)
            .offset(y: animateToggle ? 1.5 + offset : 0.0)
    }
    
    private func xpStatSummaryView(statValues: [XpStat: Int]) -> some View {
        let stats: [[XpStat]] = [[.strength, .intellect, .charm],
                                 [.fun, .sociability]]
        
        return VStack(spacing: 0) {
            ForEach(stats, id: \.self) { row in
                HStack(spacing: 4) {
                    ForEach(row, id: \.self) { stat in
                        xpStatItemView(icon: stat.image, point: statValues[stat])
                    }
                }
            }
        }
        .padding(8)
        .frame(width: 228, height: 76)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .foregroundStyle(Color.background)
        )
    }
    
    private func xpStatItemView(icon: ImageResource, point: Int?) -> some View {
        HStack(spacing: 0) {
            Image(icon)
                .resizable()
                .scaledToFit()
                .frame(width: 19, height: 19)
                .frame(width: 30, height: 30)
            
            Text("\(point ?? 0)P")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.primaryPurple)
            
            if let point = point, point > 0 {
                Image(.arrowUp)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 10)
                    .padding(.leading, 2)
            }
        }
        .padding(.horizontal, 2)
        .frame(height: 30)
    }
}

#Preview {
    SubmitCompleteView(quest: .mockData) {
        print("")
    }
}

struct EffectManager {
    static let predefinedColors: [Color] = [.yellow, .orange, .teal]
    
    static func randomColor() -> Color {
        predefinedColors.randomElement() ?? .gray
    }
    
    static func randomOffset() -> CGFloat {
        let validOffset = (Array(-3 ... -1) + Array(1...3)).map { CGFloat($0) }
        return validOffset.randomElement() ?? 0
    }
    
    static func randomSize() -> CGFloat {
        CGFloat.random(in: 3...5)
    }
    
    static func randomCornerRadius() -> CGFloat {
        CGFloat.random(in: 0...3)
    }
    
    static func randomAnimationOffset() -> CGFloat {
        CGFloat.random(in: 2...4)
    }
}

class EffectProperties: Identifiable, ObservableObject {
    let id = UUID()
    let position: (CGFloat, CGFloat)
    let size: CGFloat
    let cornerRadius: CGFloat
    let offset: CGFloat
    let color: Color
    
    init(position: (CGFloat, CGFloat)) {
        self.position = position
        self.size = EffectManager.randomSize()
        self.cornerRadius = EffectManager.randomCornerRadius()
        self.offset = EffectManager.randomOffset()
        self.color = EffectManager.randomColor()
    }
    
    static var initialProperties: [EffectProperties] =
    [(30,10), (12,18), (13,-22), (-25,-11), (-20,16)].map { EffectProperties(position: $0) }
}

class EffectViewModel: ObservableObject {
    @Published var effects: [EffectProperties] = EffectProperties.initialProperties
    @Published var staticEffects: [EffectProperties] = []
    
    init() {
        generateStaticEffects()
        generateRandomEffects()
    }
    
    func generateStaticEffects() {
        let positions: [(CGFloat, CGFloat)] = [(23,12), (-28, 8),(28, -8), (-10, -18)]
        staticEffects = positions.map { EffectProperties(position: $0) }
    }
    
    func generateRandomEffects() {
        let positions: [(CGFloat, CGFloat)] = [(26,10), (12,20), (13,-18), (-25,-11), (-20,18)]
        self.effects.removeAll()
        effects = positions.map { EffectProperties(position: $0) }
    }
}
