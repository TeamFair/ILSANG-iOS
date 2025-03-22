//
//  QuestDetailView.swift
//  ILSANG
//
//  Created by Lee Jinhee on 11/23/24.
//

import SwiftUI

struct QuestDetailView: View {
    let quest: QuestViewModelItem
    let action: () -> Void
    
    var approvalDescription: String {
        switch quest.missionType {
        case .quiz:
            "퀘스트를 지금 인증하고,\n보상을 적립받으세요!"
        case .image:
            "퀘스트를 수행하셨나요?\n인증 후 포인트를 적립받으세요"
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 2)
                .frame(width: 30, height: 4)
                .foregroundStyle(.gray100)
                .padding(.top, 8)
                .padding(.bottom, 14)

            Text("퀘스트 정보")
                .font(.system(size: 17, weight: .bold))
                .padding(.bottom, 18)
            
            QuestInfoView(quest: quest)
                .padding(.horizontal, -16)
                .padding(.vertical, -20)
            
            Divider()
                .foregroundStyle(.gray100)
                .padding(.vertical, 18)
            
            statTagViewList
                .padding(.top, 6)
            
            Text(approvalDescription)
                .font(.system(size: 14, weight: .regular))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
            
            Spacer(minLength: 0)
            
            PrimaryButton(title: "퀘스트 인증하기") {
                action()
            }
        }
        .foregroundStyle(.gray500)
        .padding(.horizontal, 20)
    }
    
    private var statTagViewList: some View {
        HStack(spacing: 12) {
            ForEach(Array(XpStat.sortedStat), id: \.rawValue) { stat in
                let point = quest.rewardDic[stat, default: 0]
                if point > 0 {
                    statTagView(stat: stat, point: point)
                }
            }
        }
        .padding(.bottom, 27)
    }
    
    private func statTagView(stat: XpStat, point: Int) -> some View {
        VStack(spacing: 8) {
            Text(stat.headerText)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(.gray500)
                .padding(.vertical, 4)
                .frame(width: 60)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .foregroundStyle(Color.background)
                )
            
            VStack(spacing: 0) {
                Image(stat.image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
                    .frame(width: 48, height: 48)
                
                HStack(spacing: 2) {
                    Text("\(point)P")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.primaryPurple)
                    Image(.arrowUp)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 12)
                }
                .frame(width: 56, height: 18)
            }
        }
    }
}

#Preview {
    QuestDetailView(quest: .mockRepeatData, action: { })
        .frame(height: 464)
}


#Preview {
    QuestDetailView(quest: .mockData, action: { })
        .frame(height: 464)
}
