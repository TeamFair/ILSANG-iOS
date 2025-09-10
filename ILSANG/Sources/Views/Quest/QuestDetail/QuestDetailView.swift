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
        quest: QuestViewModelItem,
        questRepository: QuestRepositoryInterface,
        onFavorite: @escaping (QuestViewModelItem) -> Void,
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
            .padding(.vertical, vm.quest.questType == .repeat || vm.quest.missionType == .photo ? 24 : 0)
        
            QuestDetailStatView(quest: vm.quest)
            
            Spacer(minLength: 0)
            
            Text(vm.approvalDescription)
                .font(.system(size: 14, weight: .regular))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.bottom, CGFloat.isSmallDevice ? 8 : 16)
        }
        .task {
            await vm.updateChallengeImages()
        }
        .scrollIndicators(.never)
        .foregroundStyle(.gray500)
        .safeAreaInset(
            edge: .top,
            content: {
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
            })
        .safeAreaInset(edge: .bottom) {
            PrimaryButton(title: "퀘스트 인증하기") {
                questApproveAction()
            }
            .padding(.bottom, 8)
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    QuestDetailView(
        quest: .mockData,
        questRepository:  QuestRepository(network: QuestNetwork()),
        onFavorite:  { _ in },
        showQuestExImageAction: { },
        questApproveAction: { }
    )
    .frame(height: 684)
}


#Preview {
    QuestDetailView(
        quest: .mockRepeatData,
        questRepository:  QuestRepository(network: QuestNetwork()),
        onFavorite:  { _ in },
        showQuestExImageAction: { },
        questApproveAction: { }
    )
    .frame(height: 684)
}
