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
    @Environment(\.layout) var layout
    @Environment(\.dismiss) var dismiss
    
    init(
        questRepository: QuestRepositoryInterface,
        favoriteService: FavoriteService,
        selectedCommercialArea: CommercialArea,
        questSubmissionNotifier: QuestSubmissionNotifier,
        illsangZoneManager: IllsangZoneManager
    ) {
        self._viewModel = StateObject(
            wrappedValue: FavoriteListViewModel(
                questRepository: questRepository,
                favoriteService: favoriteService,
                illsangZoneManager: illsangZoneManager,
                selectedCommercialArea: selectedCommercialArea,
                questSubmissionNotifier: questSubmissionNotifier
            )
        )
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
            .scrollDisabled(viewModel.viewStatus != .loaded || viewModel.currentItems.isEmpty)
            .refreshable {
                await viewModel.loadInitialDataWithLoadingState()
            }
        }
        .background(Color.background)
        .navigationBarBackButtonHidden()
        .task {
            await viewModel.loadDataIfNeeded()
        }
        .withQuestNavigation(questRouter: questRouter)
        .withUserNavigation(userRouter: userRouter)
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
        RegionPickerView(title: viewModel.selectedArea.areaName) {
            viewModel.showSelectRegionView = true
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 14)
        .padding(.leading, layout.horizontalPadding)
    }
    
    @ViewBuilder
    private var questListView: some View {
        if viewModel.currentItems.isEmpty {
            selectScopeView
            emptyView
        } else {
            ScrollView {
                selectScopeView
                
                LazyVStack(spacing: 8) {
                    ForEach(Array(viewModel.currentItems.enumerated()), id: \.1.id) { index, quest in
                        FavoriteQuestItemView(
                            quest: quest,
                            action: { [weak viewModel, weak questRouter] in
                                guard let viewModel = viewModel, let questRouter = questRouter else { return }
                                AnalyticsService.logEvent(.questItemClick(questId: quest.id, questType: quest.questType?.rawValue.uppercased() ?? ""))
                                questRouter.presentQuestDetail(quest: quest) { quest in
                                    viewModel.toggleFavoriteStatus(quest: quest)
                                }
                            },
                            favoriteAction: { viewModel.toggleFavoriteStatus(quest: quest) }
                        )
                        .task { await viewModel.loadMoreDataIfNeeded(at: index) }
                    }
                    
                    if viewModel.canLoadMore {
                        ProgressView()
                            .padding(.top, 12)
                    }
                }
                .padding(.top, layout.horizontalPadding)
                .padding(.bottom, layout.bottomSpacing)
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
            Task { await viewModel.loadInitialDataWithLoadingState() }
        }
    }
}

#Preview {
    FavoriteListView(
        questRepository: MockQuestRepository(),
        favoriteService: FavoriteService(favoriteNetwork: FavoriteNetwork()),
        selectedCommercialArea: .init(code: "R100", areaName: "서현", metroAreaCode: "S01"),
        questSubmissionNotifier: QuestSubmissionNotifier(),
        illsangZoneManager: IllsangZoneManager(
            areaNameService: AreaNameService(
                areaRepository: AreaRepository(network: AreaNetwork())
            )
        )
    )
}
