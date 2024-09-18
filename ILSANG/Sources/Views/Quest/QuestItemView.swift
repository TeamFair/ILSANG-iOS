//
//  QuestItemView.swift
//  ILSANG
//
//  Created by Lee Jinhee on 5/22/24.
//

import SwiftUI

struct QuestItemView: View {
    let quest: QuestViewModelItem
    let status: QuestStatus
    private let separatorOffset = 72.0
    
    var body: some View {
        HStack(spacing: 0) {
            Image(uiImage: quest.image ?? .logo)
                .resizable()
                .scaledToFill()
                .frame(width: 60, height: 60)
                .background(Color.badgeBlue)
                .clipShape(Circle())
                .padding(.leading, 20)
                .padding(.trailing, 16)
                .overlay(alignment: .top) {
                    Text(String(quest.reward) + "XP")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundStyle(.primaryPurple)
                        )
                        .offset(x: 20, y: 2)
                }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(quest.missionTitle)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.black)
                    .minimumScaleFactor(0.05)
                    .lineLimit(1)
                
                Text(quest.writer)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.gray400)
            }
            
            Spacer(minLength: 8)
            
            Group {
                switch status {
                case .uncompleted:
                    IconView(iconWidth: 12, size: .small, icon: .arrowDown, color: .gray)
                case .completed:
                    VStack(spacing: 7) {
                        IconView(iconWidth: 13, size: .small, icon: .check, color: .green)
                        Text("적립완료")
                            .font(.system(size: 12, weight: .semibold))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.green)
                    }
                }
            }
            .frame(width: separatorOffset, height: 103)
        }
        .frame(height: 103)
        .background(.white)
        .overlay(alignment: .trailing) {
            VLine()
                .stroke(style: StrokeStyle(lineWidth: 0.5, dash: [3.3]))
                .frame(width: 0.5)
                .foregroundStyle(.gray200)
                .offset(x: -separatorOffset)
                .padding(.vertical, 12)
        }
        .disabled(status == .uncompleted)
        .cornerRadius(16)
        .shadow(color: .shadow7D.opacity(0.05), radius: 20, x: 0, y: 10)
        .padding(.horizontal, 20)
    }
}


#Preview {
    VStack {
        QuestItemView(quest: QuestViewModelItem.mockData, status: .completed)
        QuestItemView(quest: QuestViewModelItem.mockData, status: .uncompleted)
    }
}
