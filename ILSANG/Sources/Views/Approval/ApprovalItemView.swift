//
//  ApprovalImageView.swift
//  ILSANG
//
//  Created by Lee Jinhee on 6/2/24.
//

import SwiftUI

struct ApprovalItemView: View, Equatable {
    static func == (lhs: ApprovalItemView, rhs: ApprovalItemView) -> Bool {
        lhs.item.id == rhs.item.id
    }
    let item: ApprovalMissionHistoryItem
    let width: CGFloat
    let height: CGFloat
    let padding: CGFloat
    let onAction: (ApprovalAction) -> Void
    
    enum ApprovalAction {
        case like
        case hate
        case profileTapped(userId: String)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ApprovalItemContentView(
                id: item.id,
                title: item.title,
                image: item.image,
                nickname: item.nickname,
                userTitle: item.userTitle,
                profileImage: item.profileImage,
                displayDate: item.displayDate,
                commercialAreaName: item.commercialAreaName,
                width: width,
                height: height
            ) {
                onAction(.profileTapped(userId: item.userId))
            }
            .equatable()
            
            ReactionView(likeCount: item.likeCount, hateCount: item.hateCount)
                .equatable()
            
            HStack(spacing: 8) {
                emojiButton(
                    imageName: .thumbsDown,
                    active: item.emojis.isSelected(.hate),
                    activeFgColor: .primary300,
                    activeBgColor: .primary100,
                    action: { onAction(.hate) }
                )
                emojiButton(
                    imageName: .thumbsUp,
                    active: item.emojis.isSelected(.like),
                    activeFgColor: .white,
                    activeBgColor: .primaryPurple,
                    action: { onAction(.like) }
                )
            }
        }
        .padding(padding)
        .background(Color.white)
        .cornerRadius(12)
    }
    
    private func emojiButton(
        imageName: UIImage,
        active: Bool,
        activeFgColor: Color,
        activeBgColor: Color,
        action: @escaping () -> ()
    ) -> some View {
        Button {
            action()
        } label: {
            Image(uiImage: imageName)
                .resizable()
                .renderingMode(.template)
                .frame(width: 27, height: 24)
                .foregroundStyle(active ? activeFgColor : .gray300)
                .frame(height: 50)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(active ? activeBgColor : .gray100)
                )
        }
    }
}


#Preview {
    ApprovalItemView(
        item: .mockDataList[0],
        width: .screenWidth-40,
        height: 200,
        padding: 20,
        onAction: { _ in}
    )
}
