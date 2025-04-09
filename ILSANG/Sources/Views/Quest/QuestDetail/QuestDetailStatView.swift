//
//  QuestDetailStatView.swift
//  ILSANG
//
//  Created by Lee Jinhee on 4/4/25.
//

import SwiftUI

struct QuestDetailStatView: View {
    let quest: QuestViewModelItem
    
    var body: some View {
        VStack(spacing: 16) {
            QuestDetailTitleView(title: "획득 가능 스탯")
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 12) {
                ForEach(Array(XpStat.sortedStat), id: \.rawValue) { stat in
                    let point = quest.rewardDic[stat, default: 0]
                    if point > 0 {
                        statTagView(stat: stat, point: point)
                    }
                }
            }
        }
    }
    
    private func statTagView(stat: XpStat, point: Int) -> some View {
        VStack(spacing: 8) {
            Text(stat.headerText)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.gray500)
                .padding(.vertical, 4)
                .frame(width: 52)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .foregroundStyle(Color.background)
                )
            
            VStack(spacing: 4) {
                Image(stat.image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25, height: 25)
                    .frame(width: 38, height: 38)
                
                HStack(spacing: 2) {
                    Text("\(point)P")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.primaryPurple)
                    Image(.arrowUp)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 12)
                        .frame(width: 20, height: 20)
                }
                .frame(width: 60, height: 20)
            }
        }
    }
}

#Preview {
    QuestDetailStatView(quest: .mockData)
}
