//
//  QuestItemView.swift
//  ILSANG
//
//  Created by Lee Jinhee on 5/22/24.
//

import SwiftUI

struct TagConfig {
    let style: TagStyle
    let image: ImageResource?
    let offset: (x: CGFloat, y: CGFloat)
    let title: String
}

// 기본 스타일
struct BaseQuestItemView<Trailing: View>: View {
    let quest: QuestItem
    let tagConfig: TagConfig?
    let imageSize: CGSize
    let trailingPadding: CGFloat
    let isDisabled: Bool
    let trailingView: Trailing
    var action: (() -> Void)? = nil
    var favoriteAction: (() -> Void)? = nil
    
    var body: some View {
        Button(action: { action?() }) {
            HStack(spacing: 0) {
                // 이미지 및 태그 뷰
                QuestImageWithTagView(
                    image: quest.image,
                    imageSize: imageSize,
                    tagConfig: tagConfig
                )
                .padding(.trailing, 20)
                
                // 텍스트 정보
                VStack(alignment: .leading, spacing: 0) {
                    Text(quest.title.forceCharWrapping)
                        .styledFont(.bold, size: 15, lineHeight: 20)
                        .foregroundColor(.black)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    Text(quest.writer)
                        .styledFont(.regular, size: 11, lineHeight: 16)
                        .foregroundColor(.gray400)
                        .padding(.bottom, 8)
                    RewardTagRow(
                        rewards: quest.rewards ?? [],
                        isMyIllsangZone: quest.isMyIllsangZone
                    )
                    
                    if let repeatStatusText = quest.repeatStatusText {
                        Text(repeatStatusText)
                            .styledFont(.caption2)
                            .foregroundStyle(.black)
                            .padding(.vertical, 2)
                            .padding(.horizontal, 8)
                            .background(
                                Capsule().fill(.gray300)
                            )
                            .padding(.top, 8)
                    }
                }
                Spacer(minLength: 0)
                
                trailingView
                    .onTapGesture {
                        favoriteAction?()
                    }
            }
            .padding(.vertical, 20)
            .padding(.leading, 20)
            .padding(.trailing, trailingPadding)
            .roundedBackground(
                cornerRadius: 12,
                bgColor: (quest.isRepeatDisabled ? Color.gray200 : Color.white)
            )
            .shadow(color: .shadow7D.opacity(0.05), radius: 20, x: 0, y: 10)
            .padding(.horizontal, 20)
        }
        .disabled(isDisabled)
    }
}


struct DefaultQuestItemView: View {
    let quest: QuestItem
    let action: (() -> Void)
    let favoriteAction: (() -> Void)
    
    var body: some View {
        BaseQuestItemView(
            quest: quest,
            tagConfig: nil,
            imageSize: .init(width: 60, height: 60),
            trailingPadding: 16,
            isDisabled: false,
            trailingView: TrailingStarView(favoriteYn: quest.favoriteYn),
            action: action,
            favoriteAction: favoriteAction
        )
    }
}

struct RepeatQuestItemView: View {
    let quest: QuestItem
    let action: (() -> Void)
    let favoriteAction: (() -> Void)
    
    var body: some View {
        BaseQuestItemView(
            quest: quest,
            tagConfig: tagConfig(for: quest.repeatType ?? .daily),
            imageSize: .init(width: 60, height: 60),
            trailingPadding: 16,
            isDisabled: false,
            trailingView: TrailingStarView(favoriteYn: quest.favoriteYn),
            action: action,
            favoriteAction: favoriteAction
        )
    }
    
    private func tagConfig(for repeatType: RepeatType) -> TagConfig {
        return TagConfig(style: .repeat(repeatType), image: nil, offset: (48, 0), title: repeatType.description)
    }
}

struct EventQuestItemView: View {
    let quest: QuestItem
    let action: (() -> Void)
    let favoriteAction: (() -> Void)
    
    var body: some View {
        BaseQuestItemView(
            quest: quest,
            tagConfig: TagConfig(style: .eventWithIcon, image: .event, offset: (48, 0), title: "한정"),
            imageSize: .init(width: 60, height: 60),
            trailingPadding: 16,
            isDisabled: false,
            trailingView: TrailingStarView(favoriteYn: quest.favoriteYn),
            action: action,
            favoriteAction: favoriteAction
        )
    }
}

struct UncompletedBannerQuestItemView: View {
    let quest: QuestItem
    let action: (() -> Void)
    
    var body: some View {
        BaseQuestItemView(
            quest: quest,
            tagConfig: tagConfig(for: quest.questType ?? .normal),
            imageSize: .init(width: 60, height: 60),
            trailingPadding: 20,
            isDisabled: false,
            trailingView: ChevronCircleView(),
            action: action
        )
    }
    
    private func tagConfig(for type: QuestType) -> TagConfig? {
        switch type {
        case .normal:
            return nil
        case .repeat:
            if let repeatType = quest.repeatType {
                return TagConfig(style: .repeat(repeatType), image: nil, offset: (48, 0), title: repeatType.description)
            } else {
                return nil
            }
        case .event:
            return TagConfig(style: .eventWithIcon, image: .event, offset: (48, 0), title: "한정")
        }
    }
    
    private func tagImage(for type: QuestType) -> ImageResource? {
        switch type {
        case .event: return .event
        default: return nil
        }
    }
}

struct FavoriteQuestItemView: View {
    let quest: QuestItem
    let action: (() -> Void)
    let favoriteAction: (() -> Void)
    
    var body: some View {
        BaseQuestItemView(
            quest: quest,
            tagConfig: tagConfig(for: quest.questType ?? .normal),
            imageSize: .init(width: 60, height: 60),
            trailingPadding: 20,
            isDisabled: false,
            trailingView: TrailingStarView(favoriteYn: quest.favoriteYn),
            action: action,
            favoriteAction: favoriteAction
        )
    }
    
    private func tagConfig(for type: QuestType) -> TagConfig? {
        switch type {
        case .normal:
            return nil
        case .repeat:
            if let repeatType = quest.repeatType {
                return TagConfig(style: .repeat(repeatType), image: nil, offset: (48, 0), title: repeatType.description)
            } else {
                return nil
            }
        case .event:
            return TagConfig(style: .eventWithIcon, image: .event, offset: (48, 0), title: "한정")
        }
    }
    
    private func tagImage(for type: QuestType) -> ImageResource? {
        switch type {
        case .event: return .event
        default: return nil
        }
    }
}

struct CompletedQuestItemView: View {
    let quest: QuestItem
    
    var body: some View {
        BaseQuestItemView(
            quest: quest,
            tagConfig: tagConfig(for: quest.questType ?? .normal),
            imageSize: .init(width: 60, height: 60),
            trailingPadding: 14,
            isDisabled: true,
            trailingView:
                VStack(spacing: 7) {
                    IconView(iconWidth: 13, size: .small, icon: .check, color: .green)
                    Text("적립완료")
                        .font(.system(size: 12, weight: .semibold))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.green)
                }
                .frame(width: 42)
        )
    }
    
    private func tagConfig(for type: QuestType) -> TagConfig? {
        switch type {
        case .normal:
            return nil
        case .repeat:
            if let repeatType = quest.repeatType {
                return TagConfig(style: .repeat(repeatType), image: nil, offset: (48, 0), title: repeatType.description)
            } else {
                return nil
            }
        case .event:
            return TagConfig(style: .eventWithIcon, image: .event, offset: (48, 0), title: "한정")
        }
    }
}

struct LargeRewardQuestItemView: View {
    let quest: QuestItem
    let action: () -> Void
    
    var body: some View {
        BaseQuestItemView(
            quest: quest,
            tagConfig: nil,
            imageSize: .init(width: 60, height: 60),
            trailingPadding: 20,
            isDisabled: false,
            trailingView: ChevronCircleView(),
            action: action
        )
    }
}

// Popular 스타일
struct PopularQuestItemView: View {
    let quest: QuestItem
    let imageSize: CGSize
    let action: () -> Void
    
    var body: some View {
        Button(action: { action() }) {
            VStack(alignment: .leading, spacing: 0) {
                Image(uiImage: quest.mainImage ?? .logo)
                    .resizable()
                    .scaledToFill()
                    .frame(width: imageSize.width, height: imageSize.height)
                    .clipped()
                    .overlay(alignment: .topTrailing) {
                        if let tagConfig = tagConfig(for: quest.questType) {
                            TagView(title: tagConfig.title, image: tagConfig.image, tagStyle: tagConfig.style)
                                .padding(16)
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
            .frame(width: imageSize.width, height: 220, alignment: .top)
            .background(
                Rectangle()
                    .foregroundStyle(.white)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    private func tagConfig(for type: QuestType?) -> TagConfig? {
        switch type {
        case .normal:
            return nil
        case .repeat:
            if let repeatType = quest.repeatType {
                return TagConfig(style: .repeat(repeatType), image: nil, offset: (48, 5), title: repeatType.description)
            } else {
                return nil
            }
        case .event:
            return TagConfig(style: .eventWithIcon, image: .event, offset: (48, 5), title: "한정")
        case .none:
            return nil
        }
    }
}

// Recommend 스타일
struct RecommendQuestItemView: View {
    let quest: QuestItem
    let action: () -> Void
    
    var body: some View {
        Button(action: { action() }) {
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
                Image(uiImage: quest.image ?? .logo)
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
                .fill(.white)
            )
        }
    }
}

#Preview {
    ScrollView {
        VStack {
            let quest = QuestItem.mockQuestList[0]
            let repeatQuest = QuestItem.mockRepeatData
            Text("인기")
            PopularQuestItemView(quest: repeatQuest, imageSize: CGSize(width: 200, height: 120), action: {})
            
            Text("큰보상")
            LargeRewardQuestItemView(quest: quest, action: {})
            
            Text("추천")
            RecommendQuestItemView(quest: quest, action: {})
            
            Text("미완료")
            DefaultQuestItemView(quest: quest, action: {}, favoriteAction: {})
            
            Text("반복")
            RepeatQuestItemView(quest: repeatQuest, action: {}, favoriteAction: {})
            
            Text("이벤트")
            EventQuestItemView(quest: quest, action: {}, favoriteAction: {})
            
            Text("배너 완료")
            CompletedQuestItemView(quest: repeatQuest)
            
            Text("배너 미완료")
            UncompletedBannerQuestItemView(quest: quest, action: {})
        }
        .padding(.vertical, 20)
        .background(Color.background)
    }
}
