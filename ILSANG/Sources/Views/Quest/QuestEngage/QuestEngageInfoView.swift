//
//  QuestInfoView.swift
//  ILSANG
//
//  Created by Lee Jinhee on 2/13/25.
//

import SwiftUI

struct QuestEngageInfoView: View {
    let quest: QuestItem
    
    var body: some View {
        HStack(spacing: 0) {
            Image(uiImage: quest.image ?? .logo)
                .resizable()
                .scaledToFill()
                .frame(width: 80, height: 80)
                .clipShape(Circle())
                .padding(.trailing, 8)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(quest.writer)
                    .styledFont(.body)
                
                Text(quest.title.forceCharWrapping)
                    .styledFont(.title2)
                    .lineLimit(2)
                
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
                        title:  quest.missionType.description,
                        tagStyle: .approvalType
                    )
                }
            }
            
            Spacer(minLength: 8)
            
            Text(String(quest.totalRewardPoint()) + "P")
                .styledFont(.heading1)
                .foregroundStyle(.primaryPurple)
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .foregroundStyle(Color.primary100)
                )
        }
        .foregroundStyle(.gray500)
        .padding(.horizontal, 16)
        .padding(.vertical, 20)
        .roundedBackground(cornerRadius: 12)
    }
}

#Preview {
    QuestEngageInfoView(quest: .mockData)
}
