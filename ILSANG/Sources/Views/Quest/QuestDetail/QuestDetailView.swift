//
//  QuestDetailView.swift
//  ILSANG
//
//  Created by Lee Jinhee on 11/23/24.
//

import SwiftUI

struct QuestDetailView: View {
    @StateObject var vm: QuestDetailViewModel
    let showQuestExImageAction: () -> Void
    let questApproveAction: () -> Void
    
    private let imageSpacing: CGFloat = 8
    private let horizontalPadding: CGFloat = 20
    
    private var contentWidth: CGFloat {
        (.screenWidth - (horizontalPadding * 2) - (imageSpacing * 2)) / 3
    }
    
    init(
        quest: QuestItem,
        questRepository: QuestRepositoryInterface,
        onFavorite: @escaping (QuestItem) -> Void,
        showQuestExImageAction: @escaping () -> (),
        questApproveAction: @escaping () -> ()
    ) {
        self._vm = StateObject(
            wrappedValue: QuestDetailViewModel(
                quest: quest,
                questRepository: questRepository,
                onFavorite: onFavorite
            )
        )
        self.questApproveAction = questApproveAction
        self.showQuestExImageAction = showQuestExImageAction
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                QuestDetailInfoView(quest: vm.quest)
                
                HStack {
                    if vm.quest.missionType == .photo {
                        QuestDetailApprovalImageView(
                            images: vm.quest.challengeImages,
                            showCount: vm.quest.questType == .repeat ? 1 : 3,
                            imageWidth: contentWidth,
                            imageSpacing: imageSpacing,
                            isLoading: vm.isLoading,
                            onTap: {
                                showQuestExImageAction()
                            }
                        )
                    }
                    
                    if vm.quest.questType == .repeat {
                        QuestDetailRepeatRankView(rank: vm.quest.userRank, contentWidth: contentWidth)
                    }
                }
                .padding(.vertical, vm.quest.questType == .repeat || vm.quest.missionType == .photo ? 20 : 0)
                
                QuestDetailStatView(quest: vm.quest)
                    .padding(.bottom, 24)
                
                if vm.quest.hasCouponReward {
                    rewardView
                        .padding(.bottom, 16)
                }
                
                Text(vm.approvalDescription)
                    .styledFont(.regular, size: 14, lineHeight: 22)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, CGFloat.isSmallDevice ? 8 : 16)
            }
            .task {
                await vm.updateChallengeImages()
            }
            .foregroundStyle(.gray500)
        }
        .scrollIndicators(.never)
        .safeAreaInset(edge: .top) {
            VStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 2)
                    .frame(width: 30, height: 4)
                    .foregroundStyle(.gray100)
                    .padding(.top, 8)
                    .padding(.bottom, 14)
                
                Text("퀘스트 정보")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(.gray500)
                    .frame(maxWidth: .infinity)
                    .overlay(alignment: .trailing) {
                        Button {
                            vm.toggleFavorite()
                        } label: {
                            Image(.star)
                                .renderingMode(.template)
                                .foregroundStyle(vm.quest.favoriteYn ? .primary300 : .gray100)
                        }
                        .padding(.bottom, 2)
                    }
                    .padding(.bottom, 12)
            }
            .background(Color.white)
        }
        .safeAreaInset(edge: .bottom) {
            PrimaryButton(
                title: "퀘스트 인증하기",
                buttonAble: vm.approvalButtonAble
            ) {
                questApproveAction()
            }
            .padding(.bottom, 4)
        }
        .padding(.horizontal, 20)
        .background(Color.white)
        .overlay {
            if let coupon = vm.quest.coupon, vm.showCouponRewardView {
                QuestCouponView(
                    coupon: coupon,
                    onDismiss: {
                        vm.showCouponRewardView = false
                    }
                )
                .padding(20)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
                .background(Color.black.opacity(0.3))
            }
        }
    }
    
    private var rewardView: some View {
        HStack(spacing: 4) {
            Text("일상존 퀘스트로\n쿠폰 확률을 높여보세요!")
                .styledFont(.tabRegular)
                .foregroundStyle(.gray500)
                .multilineTextAlignment(.leading)
            Spacer(minLength: 0)
            Button {
                vm.showCouponRewardView = true
            } label: {
                HStack(spacing: 4) {
                    Image(.treasureMinimal)
                        .resizable()
                        .scaledToFit()
                        .frame(13)
                        .frame(18)
                    Text("보상 확인")
                        .styledFont(.badge1)
                        .foregroundStyle(.white)
                }
                .padding(.vertical, 9)
                .padding(.horizontal, 12)
                .roundedBackground(cornerRadius: 12, bgColor: .primaryPurple)
            }
            .styledFont(.tabRegular)
            .foregroundStyle(.gray500)
        }
        .padding(16)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.background)
                RoundedRectangle(cornerRadius: 16)
                    .inset(by: 0.5) // 안쪽으로 0.5 inset
                    .stroke(Color.gray100, lineWidth: 1)
            }
        )
    }
}

#Preview {
    QuestDetailView(
        quest: .mockData,
        questRepository: MockQuestRepository(),
        onFavorite:  { _ in },
        showQuestExImageAction: { },
        questApproveAction: { }
    )
    .frame(height: 632)
    .frame(maxHeight: .infinity)
    .background(Color.black)
}


#Preview {
    QuestDetailView(
        quest: .mockOXData,
        questRepository: MockQuestRepository(),
        onFavorite:  { _ in },
        showQuestExImageAction: { },
        questApproveAction: { }
    )
    .frame(height: 544)
    .frame(maxHeight: .infinity)
    .background(Color.black)
}
