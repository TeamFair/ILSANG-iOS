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
                
                if quest.isRepeatQuest, let repeatType = quest.repeatType {
                    TagView(
                        title: repeatType.description,
                        tagStyle: .repeat(repeatType)
                    )
                }
            }
            
            Spacer(minLength: 4)
            
            Text(String(quest.totalRewardXP()) + "XP")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(.primaryPurple)
                .padding(.vertical, 12)
                .padding(.horizontal, 8)
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
