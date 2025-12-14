//
//  ApprovalView.swift
//  ILSANG
//
//  Created by Lee Jinhee on 5/20/24.
//

import SwiftUI

struct ApprovalView: View {
    @StateObject var vm: ApprovalViewModel
    @StateObject var questRouter: QuestRouter
    @StateObject var userRouter: UserRouter
    @EnvironmentObject var dependencies: AppDependencies
    @Environment(\.layout) var layout
    
    init(
        approvalSource: ApprovalSource,
        emojiNetwork: EmojiNetwork,
        questRepository: QuestRepositoryInterface,
        missionHistoryRepository: MissionHistoryRepositoryInterface,
        favoriteService: FavoriteService,
        areaNameService: AreaNameProvider,
        illsangZoneManager: IllsangZoneManager,
        questSubmissionNotifier: QuestSubmissionNotifier
    ) {
        _vm = StateObject(
            wrappedValue: ApprovalViewModel(
                approvalSource: approvalSource,
                emojiNetwork: emojiNetwork,
                missionHistoryRepository: missionHistoryRepository,
                favoriteService: favoriteService,
                areaNameService: areaNameService,
                questSubmissionNotifier: questSubmissionNotifier
            )
        )
        _questRouter = StateObject(
            wrappedValue: QuestRouter(
                illsangZoneManager: illsangZoneManager,
                questRepository: questRepository
            )
        )
        _userRouter = StateObject(wrappedValue: UserRouter())
    }
    
    var body: some View {
        VStack(spacing: 0) {
            switch vm.viewStatus {
            case .error:
                networkErrorView
            case .loading:
                ProgressView()
            case .loaded:
                itemView
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.background)
        .task {
            await vm.loadDataIfNeeded()
        }
        .overlay { reportAlertView }
        .withQuestNavigation(questRouter: questRouter)
        .withUserNavigation(userRouter: userRouter)
        .navigationDestination(item: $vm.selectedMissionHistory) { item in
            ApprovalDetailView(
                vm: ApprovalDetailViewModel(
                    missionHistory: item,
                    commentRepository: dependencies.commentRepository,
                    missionHistoryRepository: dependencies.missionHistoryRepository,
                    questSubmissionNotifier: dependencies.questSubmissionNotifier
                ),
                userRouter: userRouter,
                questRouter: questRouter
            )
        }
    }
    
    /// 퀘스트 타이틀  + 퀘스트 인증 이미지
    @ViewBuilder
    private var itemView: some View {
        if vm.isCurrentListEmpty {
            emptyView
        } else {
            imageListView
        }
    }
    
    private var imageListView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(Array(vm.currentItems.enumerated()), id: \.element.id) { idx, item in
                    ApprovalItemView(
                        item: item,
                        width: .screenWidth - layout.horizontalPadding * 2,
                        height: ((.screenWidth-layout.horizontalPadding * 2) / 11) * 10,
                        padding: layout.horizontalPadding,
                        showQuestInfo: vm.approvalSource == .tab,
                        onAction: { action in
                            switch action {
                            case .like:
                                vm.onLike(for: idx)
                            case .navigateToDetail:
                                vm.selectedMissionHistory = item
                            case .profileTapped(let userId):
                                userRouter.navigateToUserProfile(userId: userId)
                            case .showQuestDetail:
                                // FIXME: questId받기
                                guard let questId = item.questId else { return }
                                questRouter.presentQuestDetail(questId: questId) { updatedQuest in
                                    vm.toggleFavoriteStatus(questId: updatedQuest.id, prev: updatedQuest.favoriteYn)
                                }
                            }
                        }
                    )
                    .equatable()
                    .onTapGesture {
                        vm.selectedMissionHistory = item
                    }
                    .overlay(alignment: .topTrailing) {
                        trailingButton(for: item)
                    }
                    .task { await vm.loadMoreDataIfNeeded(at: idx ) }
                }
                
                LoadMoreIndicatorView(isVisible: vm.canLoadMore)
            }
            .padding(.top, vm.approvalSource == .tab ? 47 : 16)
            .padding(.bottom, layout.bottomSpacing)
        }
        .refreshable {
            await vm.loadInitialDataWithLoadingState()
        }
    }
    
    private func trailingButton(for item: ApprovalMissionHistoryItem) -> some View {
        Menu {
            Button {
                vm.selectedChallenge = item
                vm.showReportAlert = true
            } label: {
                Label("신고하기", image: "syren")
            }
            .foregroundStyle(.gray500)
        } label: {
            Image(.moreVertical)
                .resizable()
                .frame(width: 30, height: 30)
                .foregroundStyle(.gray500)
                .frame(height: 35)
        }
        .padding(layout.horizontalPadding)
    }
    
    @ViewBuilder
    private var reportAlertView: some View {
        if vm.showReportAlert {
            SettingAlertView(
                alertType: AlertType.Report,
                onCancel: { vm.dismissReportAlert() },
                onConfirm: { Task { await vm.confirmReport() } }
            )
        }
    }
    
    private var networkErrorView: some View {
        ErrorView(
            systemImageName: "wifi.exclamationmark",
            title: "네트워크 연결 상태를 확인해주세요",
            subTitle: "네트워크 연결 상태가 좋지 않아\n퀘스트를 불러올 수 없어요 ",
            emoticon: "🥲"
        ) {
            Task { await vm.loadInitialDataWithLoadingState() }
        }
    }
    
    private var emptyView: some View {
        ErrorView(
            title: "인증할 이미지를 불러오지 못했어요",
            subTitle: "다음에 다시 시도해주세요"
        ) {
            Task { await vm.loadInitialDataWithLoadingState() }
        }
    }
}

#Preview {
    ApprovalView(
        approvalSource: .tab,
        emojiNetwork: EmojiNetwork(),
        questRepository: QuestRepository(network: QuestNetwork()),
        missionHistoryRepository: MissionHistoryRepository(network: MissionHistoryNetwork(),),
        favoriteService: FavoriteService(favoriteNetwork: FavoriteNetwork()),
        areaNameService: AreaNameService(areaRepository: AreaRepository(network: AreaNetwork())),
        illsangZoneManager: IllsangZoneManager(areaNameService: AreaNameService(areaRepository: AreaRepository(network: AreaNetwork()))),
        questSubmissionNotifier: QuestSubmissionNotifier()
    )
}
