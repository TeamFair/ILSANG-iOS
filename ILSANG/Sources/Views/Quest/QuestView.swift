//
//  QuestView.swift
//  ILSANG
//
//  Created by Lee Jinhee on 5/19/24.
//

import SwiftUI
import Combine

struct QuestView: View {
    @StateObject var vm: QuestViewModel
    @StateObject var questRouter: QuestRouter
    @StateObject var userRouter: UserRouter
    @EnvironmentObject var dependencies: AppDependencies
    @EnvironmentObject var sharedState: SharedState
    @Environment(\.layout) var layout
    
    init(
        questRepository: QuestRepositoryInterface,
        favoriteService: FavoriteService,
        questSubmissionNotifier: QuestSubmissionNotifier,
        sharedState: SharedState,
        illsangZoneManager: IllsangZoneManager,
    ) {
        self._vm = StateObject(
            wrappedValue: QuestViewModel(
                questRepository: questRepository,
                favoriteService: favoriteService,
                illsangZoneManager: illsangZoneManager,
                questSubmissionNotifier: questSubmissionNotifier,
                sharedState: sharedState
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
            
            switch vm.viewStatus {
            case .loading:
                ProgressView().frame(maxHeight: .infinity)
            case .loaded:
                questListView
            case .error:
                networkErrorView
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.background)
        .task {
            await vm.loadDataIfNeeded()
        }
        .withQuestNavigation(questRouter: questRouter)
        .withUserNavigation(userRouter: userRouter)
        .navigationDestination(isPresented: $vm.showSelectMyRegionView) {
            MyRegionAreaSelectionView(areaRepository: dependencies.areaRepository) { area in
                vm.handleMyRegionSelection(area)
            }
        }
    }
}

extension QuestView {
    // 헤더 - 기본/반복/완료
    private var headerView: some View {
        HStack(spacing: 16) {
            ForEach(QuestStatus.allCases, id: \.headerText) { status in
                Button {
                    vm.currentCategory = status
                } label: {
                    Text(status.headerText)
                        .foregroundColor(status == vm.currentCategory ? .gray500 : .gray300)
                        .font(.system(size: 21, weight: .bold))
                        .frame(height: 30)
                }
            }
            Spacer()
        }
        .frame(height: 50)
        .padding(.horizontal, layout.horizontalPadding)
    }
    
    private var questListView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                Spacer().frame(height: 0).id("top")
                
                questListContent
            }
            .refreshable {
                await vm.reloadData()
            }
            .frame(maxWidth: .infinity)
            .overlay {
                if vm.isCurrentListEmpty {
                    questListEmptyView
                }
            }
            .onChange(of: vm.currentCategory) { _, _ in
                vm.closeFilterPicker()
                withAnimation {
                    proxy.scrollTo("top", anchor: .top)
                }
            }
            .onChange(of: vm.questFilterState.selectedValue) {  _, _ in
                vm.closeFilterPicker()
                withAnimation {
                    proxy.scrollTo("top", anchor: .top)
                }
            }
            .onChange(of: vm.repeatFilterState.selectedValue) { _, _ in
                vm.closeFilterPicker()
                withAnimation {
                    proxy.scrollTo("top", anchor: .top)
                }
            }
            .onChange(of: vm.eventFilterState.selectedValue) { _, _ in
                vm.closeFilterPicker()
                withAnimation {
                    proxy.scrollTo("top", anchor: .top)
                }
            }
        }
    }
    
    private var questListContent: some View {
        LazyVStack(spacing: 12) {
            questListView(for: vm.currentCategory)

            LoadMoreIndicatorView(isVisible: vm.canLoadMore)
        }
        .padding(.top, 100)
        .overlay(alignment: .top) {
            VStack(spacing: 16) {
                RegionPickerView(title: sharedState.selectedCommercialArea.areaName) {
                    vm.showSelectMyRegionView = true
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Group {
                    if (vm.currentCategory == .default) {
                        filterPickerDefaultView
                    } else if (vm.currentCategory == .repeat) {
                        HStack(alignment: .top, spacing: 8) {
                            filterPickerRepeatView
                            filterPickerDefaultView
                        }
                    } else if (vm.currentCategory == .event) {
                        filterPickerEventView
                    }
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(.horizontal, layout.horizontalPadding)
            .padding(.top, 2)
            .padding(.bottom, 12)
        }
        .padding(.bottom, layout.bottomSpacing)
    }

    /// 중복 제거: 헤더 타입에 따라 적절한 ItemView를 반환
    @ViewBuilder
    private func questListView(for header: QuestStatus) -> some View {
        ForEach(Array(vm.currentItems.enumerated()), id: \.1.id) { index, quest in
            questItemView(for: header, quest: quest)
                .task {
                    await vm.loadMoreDataIfNeeded(at: index)
                }
        }
    }

    /// 각 타입별 QuestItemView를 통합 관리
    @ViewBuilder
    private func questItemView(for header: QuestStatus, quest: QuestItem) -> some View {
        let action = {
            AnalyticsService.logEvent(.questItemClick(
                questId: quest.id,
                questType: quest.questType?.rawValue.uppercased() ?? ""
            ))
            questRouter.presentQuestDetail(quest: quest) { updatedQuest in
                vm.toggleFavoriteStatus(quest: updatedQuest)
            }
        }

        let favoriteAction = { vm.toggleFavoriteStatus(quest: quest) }

        switch header {
        case .default:
            DefaultQuestItemView(quest: quest, action: action, favoriteAction: favoriteAction)
        case .repeat:
            RepeatQuestItemView(quest: quest, action: action, favoriteAction: favoriteAction)
        case .event:
            EventQuestItemView(quest: quest, action: action, favoriteAction: favoriteAction)
        }
    }
    
    private var filterPickerDefaultView: some View {
        PickerView(state: vm.questFilterState, width: 150)
            .onChange(of: vm.questFilterState.selectedValue) { _, newValue in
                AnalyticsService.logEvent(.questFilterClick(filterOption: newValue.description))
            }
    }
    
    private var filterPickerRepeatView: some View {
        PickerView(state: vm.repeatFilterState, width: 85)
    }
    
    private var filterPickerEventView: some View {
        PickerView(state: vm.eventFilterState, width: 150)
    }
    
    private var questListEmptyView: some View {
        ErrorView(
            title: vm.currentCategory.emptyTitle,
            subTitle: vm.currentCategory.emptySubTitle,
            showButton: false
        )
    }
    
    private var networkErrorView: some View {
        ErrorView(
            systemImageName: "wifi.exclamationmark",
            title: "네트워크 연결 상태를 확인해주세요",
            subTitle: "네트워크 연결 상태가 좋지 않아\n퀘스트를 불러올 수 없어요",
            emoticon: "🥲"
        ) {
            Task { await vm.loadDataIfNeeded() }
        }
    }
}

#Preview {
    QuestView(
        questRepository: QuestRepository(network: QuestNetwork()),
        favoriteService: FavoriteService(favoriteNetwork: FavoriteNetwork()),
        questSubmissionNotifier: QuestSubmissionNotifier(),
        sharedState: SharedState(),
        illsangZoneManager: IllsangZoneManager(
            areaNameService: AreaNameService(
                areaRepository: AreaRepository(network: AreaNetwork())
            )
        )
    )
}
