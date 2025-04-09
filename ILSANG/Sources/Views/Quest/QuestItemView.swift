//
//  QuestItemView.swift
//  ILSANG
//
//  Created by Lee Jinhee on 5/22/24.
//

import SwiftUI

/// 공통 데이터 구조
struct QuestCommonModel {
    let title: String
    let writer: String
    let rewardDic: [XpStat: Int]
    let writerImage: UIImage?
    let image: UIImage?
    let type: String
    let target: String
    let expireDate: String
    let tagTitle: String?
    let action: (() -> Void)?
}

// 공통 퀘스트 아이템 뷰
struct QuestItemView<Style: QuestStyleProtocol>: View {
    let quest: QuestCommonModel
    let style: Style
    
    fileprivate struct Constants {
        let separatorOffset = 72.0
    }

    init(quest: QuestViewModelItem, style: Style, tagTitle: String? = nil, action: @escaping () -> Void) {
        self.quest = QuestCommonModel(
            title: quest.missionTitle,
            writer: quest.writer,
            rewardDic: quest.rewardDic, 
            writerImage: quest.image,
            image: quest.image, 
            type: quest.type,
            target: quest.target,
            expireDate: quest.expireDate,
            tagTitle: tagTitle,
            action: action
        )
        self.style = style
    }
    
    var body: some View {
        style.viewForQuest(quest: quest)
    }
}

// 기본 스타일
struct DefaultQuestView<Style: DefaultQuestStyleProtocol>: View {
    let quest: QuestCommonModel
    let style: Style
    
    var body: some View {
        Button(action: { quest.action?() }) {
            HStack(spacing: 0) {
                // 이미지 및 태그 뷰
                QuestImageWithTagView(
                    image: quest.writerImage,
                    tagTitle: quest.tagTitle ?? "",
                    tagImage: style.tagImage,
                    tagStyle: style.tagStyle ?? .xp,
                    tagOffset: style.tagOffset, 
                    imageSize: style.imageSize
                )
                .padding(.trailing, 20)
                
                // 텍스트 정보
                VStack(alignment: .leading, spacing: 4) {
                    Text(quest.title.forceCharWrapping)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.black)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    Text(quest.writer)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.gray400)
                        .padding(.bottom, 4)
                    StatGridView(
                        rewardDic: quest.rewardDic,
                        expireDate: quest.type == "EVENT" ? quest.expireDate : nil,
                        showEventTagView: Style.self != CompletedStyle.self 
                    )
                }
                Spacer(minLength: 0)
                style.trailingView()
            }
            .padding(.vertical, 20)
            .padding(.leading, 20)
            .padding(.trailing, style.trailingPadding)
            .background(style.backgroundColor)
            .cornerRadius(12)
            .overlay(alignment: .trailing) {
                style.overlayView()
            }
            .shadow(color: .shadow7D.opacity(0.05), radius: 20, x: 0, y: 10)
            .padding(.horizontal, 20)
        }
        .disabled(style.isDisabled)
    }
}


// Popular 스타일
struct PopularQuestView<Style: QuestStyleProtocol>: View {
    let quest: QuestCommonModel
    let style: Style
    let type: QuestType
    
    var body: some View {
        Button(action: { quest.action?() }) {
            VStack(alignment: .leading, spacing: 0) {
                Image(uiImage: quest.image ?? .logo)
                    .resizable()
                    .scaledToFill()
                    .frame(width: style.imageSize.width, height:  style.imageSize.height)
                    .clipped()
                    .overlay(alignment: .topTrailing) {
                        if let tagTitle = RepeatType(rawValue: quest.target.lowercased())?.description, type == .repeat {
                            TagView(title: tagTitle, tagStyle: style.tagStyle ?? .xp)
                                .offset(x: -style.tagOffset.x, y: style.tagOffset.y)
                        }  else if type == .event {
                            TagView(title: "한정", image: style.tagImage, tagStyle: style.tagStyle ?? .xp)
                                .offset(x: -style.tagOffset.x, y: style.tagOffset.y)
                        }
                    }
                    .padding(.horizontal, -16)
                    .padding(.bottom, 9)
                Text(quest.title.forceCharWrapping)
                    .font(.system(size: 15, weight: .bold))
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .lineSpacing(4)
                    .foregroundColor(.black)
                    .padding(.bottom, 4)
                Text(quest.writer)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(.gray400)
            }
            .padding(.bottom, 16)
            .padding(.horizontal, 16)
            .frame(width:style.imageSize.width, height: 220, alignment: .top)
            .background(
                Rectangle()
                    .foregroundStyle(style.backgroundColor)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

// Recommend 스타일
struct RecommendQuestView<Style: QuestStyleProtocol>: View {
    let quest: QuestCommonModel
    let style: Style

    var body: some View {
        Button(action: { quest.action?() }) {
            VStack(alignment: .leading, spacing: 0) {
                Text(quest.title.forceCharWrapping)
                    .font(.system(size: 15, weight: .bold))
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .lineSpacing(4)
                    .kerning(-0.3)
                    .foregroundColor(.black)
                    .padding(.bottom, 6)
                Text(quest.writer)
                    .font(.system(size: 10, weight: .regular))
                    .foregroundColor(.gray400)
                    .kerning(-0.3)
                Spacer(minLength: 0)
                Image(uiImage: quest.writerImage ?? .logo)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 64, height: 64)
                    .background(Color.badgeBlue)
                    .clipShape(Circle())
            }
            .padding(16)
            .padding(.top, 4)
            .frame(width: 152, height: 172, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 12)
                .fill(style.backgroundColor)
            )
        }
    }
}
