//
//  FavoriteListView.swift
//  ILLSANG
//
//  Created by Lee Jinhee on 9/6/25.
//

import SwiftUI

struct FavoriteListView: View {
    @StateObject var viewModel: FavoriteListViewModel
    @StateObject var questRouter: QuestRouter
    @StateObject var userRouter: UserRouter
    @EnvironmentObject var sharedState: SharedState
    @EnvironmentObject var dependencies: AppDependencies
    @Environment(\.dismiss) var dismiss
    
    init(
        viewModel: FavoriteListViewModel,
        questRepository: QuestRepositoryInterface,
        illsangZoneManager: IllsangZoneManager
    ) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        _questRouter = StateObject(
            wrappedValue: QuestRouter(
                illsangZoneManager: illsangZoneManager, questRepository: questRepository
            )
        )
        _userRouter = StateObject(wrappedValue: UserRouter())
    }
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
            
            VStack(spacing: 0) {
                switch viewModel.viewStatus {
                case .loading:
                    selectScopeView
                    ProgressView()
                        .frame(maxHeight: .infinity, alignment: .center)
                case .loaded:
                    questListView
                case .error:
                    selectScopeView
                    networkErrorView
                }
            }
            .scrollDisabled(viewModel.viewStatus != .loaded || viewModel.quests.isEmpty)
            .refreshable {
                await viewModel.loadInitialData()
            }
        }
        .background(Color.background)
        .navigationBarBackButtonHidden()
        .task {
            await viewModel.loadDataIfNeeded()
        }
        .withQuestNavigation(questRouter: questRouter)
        .withUserNavigation(userRouter: userRouter)
        .onChange(of: questRouter.showQuestEngage, { oldValue, newValue in
            if !newValue {
                Task { await viewModel.loadInitialData() }
            }
        })
        .onChange(of: questRouter.showSubmitRouter, { oldValue, newValue in
            if !newValue {
                Task { await viewModel.loadInitialData() }
            }
        })
        // TODO: Destination으로 변경
        .sheet(isPresented: $viewModel.showSelectRegionView) {
            MyRegionAreaSelectionView(areaRepository: dependencies.areaRepository) { area in
                viewModel.handleAreaSelection(area)
            }
        }
    }
}

extension FavoriteListView {
    private var headerView: some View {
        NavigationTitleView(title: "즐겨찾기 퀘스트", isSeparatorHidden: true, background: .background) {
            dismiss()
        }
        .padding(.bottom, 8)
    }
    
    private var selectScopeView: some View {
        RegionPickerView(title: sharedState.selectedCommercialArea.areaName) {
            viewModel.showSelectRegionView = true
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 14)
        .padding(.leading, 20)
    }
    
    @ViewBuilder
    private var questListView: some View {
        if viewModel.quests.isEmpty {
            selectScopeView
            emptyView
        } else {
            ScrollView {
                selectScopeView
                
                LazyVStack(spacing: 8) {
                    ForEach(viewModel.quests, id: \.id) { quest in
                        FavoriteQuestItemView(
                            quest: quest,
                            action: {
                                AnalyticsService.logEvent(.questItemClick(questId: quest.id, questType: quest.questType?.rawValue.uppercased() ?? ""))
                                questRouter.presentQuestDetail(quest: quest) { quest in
                                    viewModel.toggleFavoriteStatus(quest: quest)
                                }
                            },
                            favoriteAction: { viewModel.toggleFavoriteStatus(quest: quest) }
                        )
                    }
                    
                    if viewModel.paginationManager.canLoadMoreData() {
                        ProgressView()
                            .task { await viewModel.loadMoreData() }
                    }
                }
                .padding(.top, 20)
                .padding(.bottom, 72)
            }
        }
    }
    
    private var emptyView: some View {
        ErrorView(
            title: "즐겨찾기한 퀘스트가 없어요",
            subTitle: "관심 있는 지역의 퀘스트를\n즐겨찾기 해보세요!",
            buttonTitle: "퀘스트 바로가기"
        ) {
            sharedState.selectedTab = .home
            dismiss()
        }
    }
    private var networkErrorView: some View {
        ErrorView(
            systemImageName: "wifi.exclamationmark",
            title: "네트워크 연결 상태를 확인해주세요",
            subTitle: "네트워크 연결 상태가 좋지 않아\n퀘스트를 불러올 수 없어요",
            emoticon: "🥲"
        ) {
            Task { await viewModel.loadInitialData() }
        }
    }
}

#Preview {
    FavoriteListView(
        viewModel: FavoriteListViewModel(
            questRepository: MockQuestRepository(),
            favoriteService: FavoriteService(favoriteNetwork: FavoriteNetwork()),
            selectedCommercialArea: .init(code: "R100", areaName: "서현", metroAreaCode: "S01")
        ),
        questRepository: QuestRepository(network: QuestNetwork()),
        illsangZoneManager: IllsangZoneManager(
            areaNameService: AreaNameService(
                areaRepository: AreaRepository(network: AreaNetwork())
            ),
            seasonManager: SeasonManager(
                seasonNetwork: SeasonNetwork()
            )
        )
    )
}
