//
//  ApprovalImageView.swift
//  ILSANG
//
//  Created by Lee Jinhee on 6/2/24.
//

import SwiftUI

struct ApprovalItemView: View {
    let item: ApprovalViewModelItem
    
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

struct ApprovalItemContentView: View {
    let item: ApprovalViewModelItem
    
    let width: CGFloat
    let height: CGFloat
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            profileView(nickname: item.nickname, time: item.time)
            
            Text(item.title)
                .font(.system(size: 23, weight: .bold))
                .frame(height: 24)
                .foregroundStyle(.black)
            
            Image(uiImage: item.image ?? .logo)
                .resizable()
                .scaledToFill()
                .frame(width: width, height: height)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .allowsHitTesting(false)
            
            HStack(spacing: 16) {
                emojiView(imageName: .thumbsUp, count: item.likeCnt, alignment: .top)
                emojiView(imageName: .thumbsDown, count: item.hateCnt, alignment: .bottom)
            }
        }
    }
    
    private func profileView(nickname: String, time: String) -> some View {
        HStack(spacing: 10) {
            Image(.profileCircle)
                .resizable()
                .frame(width: 35, height: 35)
            VStack(alignment: .leading, spacing: 3) {
                Text(nickname)
                    .font(.system(size: 14, weight: .semibold))
                Text(time)
                    .font(.system(size: 12, weight: .regular))
            }
            .foregroundStyle(.gray500)
        }
    }
    
    private func emojiView(imageName: UIImage, count: Int, alignment: Alignment) -> some View {
        HStack(spacing: 4) {
            Image(uiImage: imageName)
                .resizable()
                .renderingMode(.template)
                .scaledToFit()
                .frame(width: 21, height: 21)
                .foregroundStyle(.gray200)
                .frame(width: 24, height: 24, alignment: alignment)
            Text(String(count))
                .monospacedDigit()
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(.gray300)
        }
        .frame(height: 24)
    }
}
#Preview {
    ApprovalItemView(
        item: .mockDataList[0],
        width: .screenWidth-40,
        height: 200,
        padding: 20,
        onLike: { },
        onHate: { })
}
