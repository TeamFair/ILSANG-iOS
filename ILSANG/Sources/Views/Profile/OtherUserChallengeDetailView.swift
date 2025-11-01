//
//  OtherUserChallengeDetailView.swift
//  ILSANG
//
//  Created by Lee Jinhee on 3/8/25.
//

import SwiftUI

struct OtherUserChallengeDetailView: View {
    @ObservedObject var vm: OtherUserProfileViewModel
    
    let missionHistory: UserMissionHistoryItem
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            NavigationTitleView(title: "챌린지 정보", isSeparatorHidden: true) {
                dismiss()
            }
            .overlay(alignment: .trailing) {
                if missionHistory.missionType == .photo {
                    trailingButton /// 공유 & 삭제 버튼
                }
            }
            .padding(.bottom, 8)
            
            ScrollView {
                VStack(spacing: 0) {
                    if let detailItem = vm.selectedMissionHistoryDetail {
                        if missionHistory.missionType == .photo {
                            SubmittedImageView(image: missionHistory.submitImage)
                        }
                        
                        UserMissionHistoryInfoView(missionHistory: detailItem)
                        
                        UserMissionHistoryInfoSectionView(
                            metroPoint: detailItem.metroGainPoint,
                            commercialPoint: detailItem.commercialGainPoint,
                            contributionPoint: detailItem.contributionGainPoint,
                            isMyIllsangZone: detailItem.isMyIllsangZone,
                            writer: detailItem.writerName,
                            createdAt: detailItem.createdAt.timeAgoCreatedAt(),
                        )
                    }
                }
            }
            .background(Color.background)
            .task {
                await vm.fetchMissionHistoryDetail(
                    id: missionHistory.missionHistoryId,
                    submitImage: missionHistory.submitImage
                )
            }
        }
        .navigationBarBackButtonHidden()
    }
    
    private var trailingButton: some View {
        Menu {
            ShareLink(item: photo, preview: SharePreview(photo.caption, image: photo.image)) {
                Label("공유하기", image: "share")
            }
        } label: {
            Image(.moreVertical)
                .resizable()
                .frame(width: 30, height: 30)
                .foregroundStyle(.gray500)
        }
        .padding(.trailing, 12)
    }
    
    // MARK: - 챌린지 이미지 공유하기
    private var photo: TransferableUIImage {
        return .init(uiimage: dailyShareUIImage, caption: "일상 챌린지 공유하기")
    }
    
    private var dailyShareUIImage: UIImage {
        let renderer = ImageRenderer(
            content: SubmittedImageView(image: missionHistory.submitImage ?? .logo).frame(width: 440) // FIXME: 공유 이미지 변경
        )
        renderer.scale = 3.0
        return renderer.uiImage ?? .init()
    }
}
