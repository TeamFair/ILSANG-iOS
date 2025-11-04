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
                    vm.selectedHeader = status
                } label: {
                    Text(status.headerText)
                        .foregroundColor(status == vm.selectedHeader ? .gray500 : .gray300)
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
                await vm.refreshData()
            }
            .frame(maxWidth: .infinity)
            .overlay {
                if vm.isCurrentListEmpty {
                    questListEmptyView
                }
            }
            .onChange(of: vm.selectedHeader) { _, _ in
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
            switch vm.selectedHeader {
            case .default: // 미완료 퀘스트
                ForEach(vm.currentQuests, id: \.id) { quest in
                    DefaultQuestItemView(
                        quest: quest,
                        action: {
                            AnalyticsService.logEvent(.questItemClick(questId: quest.id, questType: quest.questType?.rawValue.uppercased() ?? ""))
                            questRouter.presentQuestDetail(quest: quest) { quest in
                                vm.toggleFavoriteStatus(quest: quest)
                            }
                        },
                        favoriteAction: { vm.toggleFavoriteStatus(quest: quest) }
                    )
                }
            case .repeat: // 미완료 반복 퀘스트
                ForEach(vm.currentQuests, id: \.id) { quest in
                    RepeatQuestItemView(
                        quest: quest,
                        action: {
                            AnalyticsService.logEvent(.questItemClick(questId: quest.id, questType: quest.questType?.rawValue.uppercased() ?? ""))
                            questRouter.presentQuestDetail(quest: quest) { quest in
                                vm.toggleFavoriteStatus(quest: quest)
                            }
                        },
                        favoriteAction: { vm.toggleFavoriteStatus(quest: quest) }
                    )
                }
            case .event: // 미완료 이벤트 퀘스트
                ForEach(vm.currentQuests, id: \.id) { quest in
                    EventQuestItemView(
                        quest: quest,
                        action: {
                            AnalyticsService.logEvent(.questItemClick(questId: quest.id, questType: quest.questType?.rawValue.uppercased() ?? ""))
                            questRouter.presentQuestDetail(quest: quest) { quest in
                                vm.toggleFavoriteStatus(quest: quest)
                            }
                        },
                        favoriteAction: { vm.toggleFavoriteStatus(quest: quest) }
                    )
                }
            }
        }
        .padding(.top, 100)
        .overlay(alignment: .top) {
            VStack(spacing: 16) {
                RegionPickerView(title: sharedState.selectedCommercialArea.areaName) {
                    vm.showSelectMyRegionView = true
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Group {
                    if (vm.selectedHeader == .default) {
                        filterPickerDefaultView
                    } else if (vm.selectedHeader == .repeat) {
                        HStack(alignment: .top, spacing: 8) {
                            filterPickerRepeatView
                            filterPickerDefaultView
                        }
                    } else if (vm.selectedHeader == .event) {
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
            title: vm.selectedHeader.emptyTitle,
            subTitle: vm.selectedHeader.emptySubTitle,
            showButton: false
        )
    }
    
    private var networkErrorView: some View {
        ErrorView(
            systemImageName: "wifi.exclamationmark",
            title: "네트워크 연결 상태를 확인해주세요",
            subTitle: "네트워크 연결 상태가 좋지 않아\n퀘스트를 불러올 수 없어요 ",
            emoticon: "🥲"
        ) {
            Task { await vm.loadInitialData() }
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
