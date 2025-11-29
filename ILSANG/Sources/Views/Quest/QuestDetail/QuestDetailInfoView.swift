//
//  QuestDetailInfoView.swift
//  ILSANG
//
//  Created by Lee Jinhee on 4/4/25.
//

import SwiftUI

struct QuestDetailInfoView: View {
    let quest: QuestItem
    
    var body: some View {
        HStack(spacing: 0) {
            Image(uiImage: quest.image ?? .logo)
                .resizable()
                .scaledToFill()
                .frame(width: CGFloat.isSmallDevice ? 60 : 80, height: CGFloat.isSmallDevice ? 60 : 80)
                .clipShape(Circle())
                .padding(.trailing, 8)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 4) {
                    // 이벤트 퀘스트 태그
                    if quest.questType == .event {
                        TagView(title: "한정", image: .event, tagStyle: .eventWithIcon)
                    }
                    
                    // 반복 퀘스트 태그
                    if quest.questType == .repeat, let repeatType = quest.repeatType {
                        TagView(
                            title: repeatType.description,
                            tagStyle: .repeat(repeatType)
                        )
                    }
                    
                    // 인증방법 태그 (사진, 서술형, OX)
                    TagView(
                        title: quest.missionType.description,
                        tagStyle: .approvalType
                    )
                }
                
                Text(quest.title.forceCharWrapping)
                    .styledFont(.title2)
                    .lineLimit(2)
                
                if let repeatStatusText = quest.repeatStatusText {
                    Text(repeatStatusText)
                        .styledFont(.caption2)
                        .foregroundStyle(.black)
                        .padding(.vertical, 2)
                        .padding(.horizontal, 8)
                        .background(
                            Capsule().fill(.gray300)
                        )
                }
                
                if quest.questType == .event, let date = quest.expireDate {
                    Text(date.toDisplayFormat(.short)+"까지")
                        .styledFont(.caption2)
                        .padding(.top, -6)
                        .padding(.bottom, 2)
                        .foregroundStyle(.gray400)
                }
            }
            
            Spacer(minLength: 8)
            
            Text(String(quest.totalRewardPoint()) + "P")
                .styledFont(.heading1)
                .foregroundStyle(.primaryPurple)
                .padding(10)
                .roundedBackground(cornerRadius: 12, bgColor: .primary100)
        }
        .foregroundStyle(.gray500)
        .frame(minHeight: 80, maxHeight: 92)
        .padding(.vertical, 16)
    }
}


#Preview {
    QuestDetailInfoView(quest: .mockData)
}
