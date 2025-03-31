//
//  QuestInfoView.swift
//  ILSANG
//
//  Created by Lee Jinhee on 2/13/25.
//

import SwiftUI

struct QuestInfoView: View {
    let quest: QuestViewModelItem
    
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
                    .styledFont(.regular, size: 15, lineHeight: 30)
                
                Text(quest.missionTitle.forceCharWrapping)
                    .styledFont(.bold, size: 18, lineHeight: 30)
                    .kerning(-0.2)
                    .lineLimit(2)
                
                HStack(spacing: 2) {
                    // 반복 퀘스트 태그
                    if quest.isRepeatQuest, let repeatType = quest.repeatType {
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
            
            Text(String(quest.totalRewardXP()) + "XP")
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
    QuestInfoView(quest: .mockData)
}
