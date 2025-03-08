//
//  MyPagePointSectionView.swift
//  ILSANG
//
//  Created by Lee Jinhee on 1/10/25.
//

import SwiftUI

struct MyPagePointSectionView: View {
    let currentXp: Int?
    let currentLv: Int
    let remainXp: Int
    let progress: Double
    
    init(currentXp: Int) {
        self.currentXp = currentXp
        self.currentLv = XpLevelCalculator.convertXPtoLv(xp: currentXp)
        self.remainXp =  XpLevelCalculator.xpForNextLv(xp: currentXp)
        
        let levelData = XpLevelCalculator.xpProgressInCurrentLevel(xp: currentXp, level: currentLv)
        self.progress = XpLevelCalculator.calculateProgress(currentValue: levelData.currentLevelXP, totalValue: levelData.requiredXPForNextLevel)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("총 포인트")
                .font(.system(size: 12))
                .foregroundColor(.gray400)
            
            Text("\(String(currentXp ?? 0).formatNumberInText())XP")
                .font(.system(size: 23, weight: .bold))
                .foregroundColor(.gray500)
            
            ProgressBar(progress: progress)
                .frame(height: 10)
                .padding(.top, 10)
            
            HStack {
                Text("LV.\(currentLv)")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.gray200)
                
                Spacer()
                
                Text("다음 레벨까지 \(remainXp)XP 남았어요!")
                    .font(.system(size: 13))
                    .foregroundColor(.gray400)
                
                Spacer()
                
                Text("LV.\(currentLv + 1)")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.accent)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .background(.white)
        .cornerRadius(12)
    }
}

#Preview {
    VStack {
        MyPagePointSectionView(currentXp: 10)
    }
    .padding()
    .background(Color.background)
}
