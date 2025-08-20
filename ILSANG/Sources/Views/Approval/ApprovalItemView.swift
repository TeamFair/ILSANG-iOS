//
//  ApprovalImageView.swift
//  ILSANG
//
//  Created by Lee Jinhee on 6/2/24.
//

import SwiftUI

struct ApprovalItemView: View {
    let item: ApprovalMissionHistoryItem
    
    let width: CGFloat
    let height: CGFloat
    
    let padding: CGFloat
    let onLike: () -> Void
    let onHate: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ApprovalItemContentView(item: item, width: width, height: height)
            
            HStack(spacing: 8) {
                emojiButton(
                    imageName: .thumbsDown,
                    active: item.emoji?.isHate ?? false,
                    activeFgColor: .primary300,
                    activeBgColor: .primary100,
                    action: { onHate() }
                )
                emojiButton(
                    imageName: .thumbsUp,
                    active: item.emoji?.isLike ?? false,
                    activeFgColor: .white,
                    activeBgColor: .primaryPurple,
                    action: { onLike() }
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
        onLike: { },
        onHate: { }
    )
}
