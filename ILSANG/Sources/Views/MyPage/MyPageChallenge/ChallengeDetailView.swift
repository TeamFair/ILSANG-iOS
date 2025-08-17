//
//  ChallengeDetailView.swift
//  ILSANG
//
//  Created by Kim Andrew on 5/31/24.
//

import SwiftUI

struct ChallengeDetailView: View {
    
    @Environment(\.dismiss) var dismiss
    @ObservedObject var vm: MyPageViewModel
    
    let idx: Int
    
    init(vm: MyPageViewModel, idx: Int) {
        self.vm = vm
        self.idx = idx
    }
    
    var body: some View {
        VStack(spacing: 0) {
            NavigationTitleView(title: "챌린지 정보", isSeparatorHidden: false) {
                dismiss()
            }
            .overlay(alignment: .trailing) {
                trailingButton /// 공유 & 삭제 버튼
            }
            .padding(.bottom, 8) // 세로로 긴 이미지 대응 (NavigationTitleView의 bottom 패딩과 겹침)
            
            if vm.challengeList.indices.contains(idx) {
                if let missionImage = vm.challengeList[idx].challengeImage {
                    ChallengeImageView(missionImage: missionImage, challengeData: vm.challengeList[idx])
                } else if vm.challengeList[idx].challengeImage == nil {
                    ChallengeImageView(missionImage: nil, challengeData: vm.challengeList[idx])
                } else {
                    ErrorView(title: "챌린지 정보를 불러오지 못했어요", subTitle: "챌린지 정보를 불러오는 데 실패했어요.\n인터넷 연결 상태 확인 후 다시 시도해주세요.") {
                        Task {
                            if let challengeImageId = vm.challengeList[idx].challengeImageId {
                                vm.challengeList[idx].challengeImage = await vm.getImage(imageId: challengeImageId)
                            }
                        }
                    }
                }
            }
        }
        .background(Color.background)
        .navigationBarBackButtonHidden()
        .task {
            if let questImageId = vm.challengeList[idx].writerImageId {
                self.vm.challengeList[idx].writerImage = await vm.getImage(imageId: questImageId)
            }
        }
        .overlay {
            if vm.challengeDelete {
                SettingAlertView(
                    alertType: .ChallengeDelete,
                    onCancel: { vm.challengeDelete = false },
                    onConfirm: {
                        Task {
                            if await vm.updateChallengeStatus(challengeId: vm.challengeList[idx].challengeId, imageId: vm.challengeList[idx].challengeImageId) {
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
        guard vm.challengeList.indices.contains(idx) else {
            return UIImage()
        }
        
        let renderer = ImageRenderer(
            content: ChallengeImageView(missionImage: vm.challengeList[idx].challengeImage ?? .logo, challengeData: vm.challengeList[idx]).frame(width: 440)
        )
        renderer.scale = 3.0
        return renderer.uiImage ?? .init()
    }
}

struct ChallengeImageView: View {
    let missionImage: UIImage?
    let challengeData : ChallengeViewModelItem
    
    var body: some View {
        if let missionImage {
            Image(uiImage: missionImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .overlay(alignment: .bottom) {
                    challengeInfoView /// 도전내역 정보 컴포넌트
                }
        }else {
            Image(uiImage:.logoWithAlpha)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 72)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.bottom, 80)
                .overlay(alignment: .bottom) {
                    challengeInfoView /// 도전내역 정보 컴포넌트
                }
        }
    }
    
    private var challengeInfoView: some View {
        HStack(spacing: 0) {
            if let writerImage = challengeData.writerImage {
                Image(uiImage: writerImage)
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
            ChallengeDetailView(
                vm: MyPageViewModel(
                    userNetwork: UserNetwork(),
                    challengeNetwork: ChallengeNetwork(),
                    imageNetwork: ImageNetwork(),
                    pointNetwork: PointNetwork()
                ),
                idx: 0
            )
        }
        .tabItem {
            Label("탭", image: "profile")
        }
    }
}
