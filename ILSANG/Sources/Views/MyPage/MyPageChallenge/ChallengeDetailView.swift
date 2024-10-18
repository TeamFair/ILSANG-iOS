//
//  ChallengeDetailView.swift
//  ILSANG
//
//  Created by Kim Andrew on 5/31/24.
//

import SwiftUI

struct ChallengeDetailView: View {
    
    @Environment(\.dismiss) var dismiss
    @ObservedObject var vm: MypageViewModel
    
    @State private var missionImage: UIImage?
    @State private var questImage: UIImage?
    
    let challengeData : Challenge
    
    var body: some View {
        VStack(spacing: 0) {
            NavigationTitleView(title: "챌린지 정보", isSeparatorHidden: false) {
                dismiss()
            }
            .overlay(alignment: .trailing) {
                trailingButton /// 공유 & 삭제 버튼
            }
            .padding(.bottom, 8) // 세로로 긴 이미지 대응 (NavigationTitleView의 bottom 패딩과 겹침)
            
            if let missionImage = missionImage {
                ChallengeImageView(missionImage: missionImage, questImage: questImage, challengeData: challengeData)
            } else {
                ErrorView(title: "챌린지 정보를 불러오지 못했어요", subTitle: "챌린지 정보를 불러오는 데 실패했어요.\n인터넷 연결 상태 확인 후 다시 시도해주세요.") {
                    Task {
                        missionImage = await vm.getImage(imageId: challengeData.receiptImageId)
                    }
                }
            }
        }
        .background(Color.background)
        .navigationBarBackButtonHidden()
        .task {
            missionImage = await vm.getImage(imageId: challengeData.receiptImageId)
            if let questImageId = challengeData.questImageId {
                self.questImage = await vm.getImage(imageId: questImageId)
            }
        }
        .overlay {
            if vm.challengeDelete {
                SettingAlertView(
                    alertType: .ChallengeDelete,
                    onCancel: { vm.challengeDelete = false },
                    onConfirm: {
                        Task {
                            if await vm.updateChallengeStatus(challengeId: challengeData.challengeId,ImageId: challengeData.receiptImageId) {
                                vm.challengeDelete = false
                                dismiss()
                            } else {
                                vm.challengeDelete = false
                            }
                        }
                    }
                )
            }
        }
    }
    
    private var trailingButton: some View {
        Menu {
            ShareLink(item: photo, preview: SharePreview(photo.caption, image: photo.image)) {
                Label("공유하기", image: "share")
            }
            Button {
                vm.challengeDelete.toggle()
            } label: {
                Label("삭제하기", image: "trash")
            }
            .foregroundStyle(.gray500)
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
            content: ChallengeImageView(missionImage: missionImage ?? .logo, questImage: questImage ?? .logo, challengeData: challengeData).frame(width: 440)
        )
        renderer.scale = 3.0
        return renderer.uiImage ?? .init()
    }
}

struct ChallengeImageView: View {
    let missionImage: UIImage
    let questImage: UIImage?
    let challengeData : Challenge

    var body: some View {
        Image(uiImage: missionImage)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(alignment: .bottom) {
                challengeInfoView /// 도전내역 정보 컴포넌트
            }
    }
    
    private var challengeInfoView: some View {
        HStack(spacing: 0) {
            if let questImage = questImage {
                Image(uiImage: questImage)
                    .resizable()
                    .frame(width: 48, height: 48)
                    .background(.primary100)
                    .clipShape(Circle())
                    .padding(.trailing, 8)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(challengeData.missionTitle ?? "")
                    .font(.system(size: 17, weight: .bold))
                    .kerning(-0.3)
                    .foregroundColor(.black)
                HStack(spacing: 4) {
                    Image(.heart)
                        .resizable()
                        .frame(width: 10, height: 9)
                    Text("\(challengeData.likeCnt)")
                        .font(.system(size: 12, weight: .regular))
                }
                .foregroundColor(.gray500)
            }
            
            Spacer(minLength: 0)
            
            Text("1/1")
                .font(.system(size: 13, weight: .semibold))
                .padding(.horizontal, 11)
                .frame(height: 20)
                .foregroundColor(.white)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .foregroundStyle(.gray300)
                )
        }
        .padding(.horizontal, 9.5)
        .padding(.vertical, 20)

        .background(
            RoundedRectangle(cornerRadius: 12)
                .foregroundStyle(.white)
        )
        .padding(20)
    }
}


#Preview {
    TabView {
        NavigationStack {
            ChallengeDetailView(vm: MypageViewModel(userNetwork: UserNetwork(), challengeNetwork: ChallengeNetwork(), imageNetwork: ImageNetwork(), xpNetwork: XPNetwork()), challengeData: Challenge.challengeMockData)
        }
        .tabItem {
            Label("탭", image: "profile")
        }
    }
}
