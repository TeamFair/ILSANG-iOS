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
    let showQuestInfo: Bool
    let onAction: (ApprovalAction) -> Void
    
    enum ApprovalAction {
        case like
        case navigateToDetail
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
            
            if showQuestInfo {
                ApprovalQuestView(
                    questType: item.questType ?? .normal,
                    repeatType: item.repeatType,
                    questTitle: item.title,
                    writerName: item.writer ?? "",
                    bgStyle: .roundedStroke,
                    status: item.questStatus,
                    action: {
                        // FIXME: 퀘스트 라우터 연결
                    }
                )
            }
            
            HStack(spacing: 16) {
                button(
                    imageName: item.emojis.isSelected(.like) ? .likeFill : .like ,
                    imageColor: item.emojis.isSelected(.like) ? .primaryPurple : .gray400,
                    count: item.likeCount,
                    action: { onAction(.like) }
                )
                button(
                    imageName: .chat,
                    imageColor: .gray400,
                    count: item.commentCount,
                    action: { onAction(.navigateToDetail) }
                )
                
                ShareLink(item: photo, preview: SharePreview(photo.caption, image: photo.image)) {
                    button(
                        imageName: .share,
                        imageColor: .gray400,
                        count: item.shareCount,
                        action: {  } // FIXME: 공유 시 카운트 올리기
                    )
                    .disabled(true)
                }
            }
        }
        .padding(padding)
        .background(Color.white)
        .cornerRadius(12)
    }
    
    private func button(
        imageName: UIImage,
        imageColor: Color = .gray400,
        count: Int,
        action: @escaping () -> ()
    ) -> some View {
        Button {
            action()
        } label: {
            HStack(spacing: 4) {
                Image(uiImage: imageName)
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: 27, height: 22)
                    .foregroundStyle(imageColor)
                    .frame(width: 30, height: 30)
                Text("\(count)")
                    .monospacedDigit()
                    .styledFont(.subTitle1)
                    .foregroundStyle(.gray400)
            }
            .frame(height: 30)
        }
    }
    
    // MARK: - 챌린지 이미지 공유하기
    private var photo: TransferableUIImage {
        return .init(uiimage: shareChallengeImage, caption: "일상 챌린지 공유하기")
    }
    
    private var shareChallengeImage: UIImage {
        let renderer = ImageRenderer(
            content: ApprovalItemContentShareView(
                item: item,
                width: .screenWidth-40,
                height: ((.screenWidth-40) / 11) * 10
            )
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.white)
            )
        )
        
        renderer.scale = 3.0
        return renderer.uiImage ?? .init()
    }
}


#Preview {
    ApprovalItemView(
        item: .mockDataList[0],
        width: .screenWidth-40,
        height: 200,
        padding: 20,
        showQuestInfo: true,
        onAction: { _ in}
    )
}
