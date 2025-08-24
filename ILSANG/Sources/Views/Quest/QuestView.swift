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
    @EnvironmentObject var sharedState: SharedState

    init() {
        #if DEBUG
        _vm = StateObject(
            wrappedValue: QuestViewModel(
                questRepository: MockQuestRepository(),
                favoriteService: FavoriteService(favoriteNetwork: FavoriteNetwork())
            )
        )
        #else
        _vm = StateObject(
            wrappedValue: QuestViewModel(
                questRepository: QuestRepository(network: QuestNetwork()),
                favoriteService: FavoriteService(favoriteNetwork: FavoriteNetwork())
            )
        )
        #endif
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
        .onReceive(
            vm.$selectedHeader
                .combineLatest(vm.questFilterState.$selectedValue)
                .combineLatest(vm.repeatFilterState.$selectedValue)
                .combineLatest(vm.eventFilterState.$selectedValue)
        ) { _ in
            vm.closeFilterPicker()
        }
        .sheet(isPresented: $vm.showQuestSheet) {
            let tall = vm.selectedQuest.questType == .repeat || vm.selectedQuest.missionType == .photo
            
            QuestDetailView(
                vm: QuestDetailViewModel(
                    quest: vm.selectedQuest,
                    questRepository: QuestRepository(network: QuestNetwork()),
                    onUpdate: { quest in
                        vm.toggleFavoriteStatus(quest: quest)
                    })
            ) {
                vm.onQuestApprovalTapped()
            }
            .presentationCornerRadius(24)
            .presentationDragIndicator(.hidden)
            .presentationDetents([tall ? .height(UISheetPresentationController.Detent.questDetailDetentHeightTall) : .height(UISheetPresentationController.Detent.questDetailDetentHeightShort)])
            .onAppear {
                UIApplication.shared.updateSheetDetents(to: [tall ? .questDetailDetentTall : .questDetailDetentShort], whenCurrentDetentsAre: [.large()])
            }
        }
        .fullScreenCover(isPresented: $vm.showSubmitRouterView) {
            SubmitRouterView(selectedQuest: vm.selectedQuest)
                .interactiveDismissDisabled()
        }
        .navigationDestination(isPresented: $vm.showQuestEngageView) {
            let challengeNetwork = ChallengeNetwork()
            
            QuestEngageView(
                vm: QuestEngageViewModel(quest: vm.selectedQuest, quizNetwork: QuizNetwork()),
                submitVM: SubmitRouterViewModel(
                    selectedImage: nil,
                    selectedQuest: vm.selectedQuest,
                    submitService: ImageChallengeSubmitService(imageNetwork: ImageNetwork(), challengeNetwork: challengeNetwork),
                    challengeNetwork: challengeNetwork
                )
            )
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
        .padding(.horizontal, 20)
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
            .onReceive(
                vm.$selectedHeader
                        .combineLatest(vm.questFilterState.$selectedValue)
                        .combineLatest(vm.repeatFilterState.$selectedValue)
                        .combineLatest(vm.eventFilterState.$selectedValue)
            ) { _ in
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
                        action: { vm.onQuestTapped(quest: quest) },
                        favoriteAction: { vm.toggleFavoriteStatus(quest: quest) }
                    )
                }
            case .repeat: // 미완료 반복 퀘스트
                ForEach(vm.currentQuests, id: \.id) { quest in
                    RepeatQuestItemView(
                        quest: quest,
                        action: { vm.onQuestTapped(quest: quest) },
                        favoriteAction: { vm.toggleFavoriteStatus(quest: quest) }
                    )
                }
            case .event: // 미완료 이벤트 퀘스트
                ForEach(vm.currentQuests, id: \.id) { quest in
                    EventQuestItemView(
                        quest: quest,
                        action: { vm.onQuestTapped(quest: quest) },
                        favoriteAction: { vm.toggleFavoriteStatus(quest: quest) }
                    )
                }
            case .completed: // 완료 퀘스트
                ForEach(vm.currentQuests, id: \.id) { quest in
                   CompletedQuestItemView(quest: quest)
                }
                
                if vm.hasMorePage(status: .completed) {
                    ProgressView()
                        .task {
                            await vm.completedPaginationManager.loadData(isRefreshing: false)
                        }
                }
            }
        }
        .padding(.top, vm.selectedHeader != .completed ? 70 : 0)
        .overlay(alignment: .top) {
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
            .padding(.top, 13)
            .padding(.bottom, 16)
            .padding(.trailing, 20)
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.bottom, 72)
    }
    
    private var filterPickerDefaultView: some View {
        PickerView<QuestFilterType>(
            status: $vm.questFilterState.pickerStatus,
            selection: $vm.questFilterState.selectedValue,
            width: 150
        )
        .onChange(of: vm.questFilterState.selectedValue) { _, newValue in
            AnalyticsService.logEvent(.questFilterClick(filterOption: newValue.description))
        }
    }
    
    private var filterPickerRepeatView: some View {
        PickerView<RepeatType>(
            status: $vm.repeatFilterState.pickerStatus,
            selection: $vm.repeatFilterState.selectedValue,
            width: 85
        )
    }
    
    private var filterPickerEventView: some View {
        PickerView<EventQuestFilterType>(
            status: $vm.eventFilterState.pickerStatus,
            selection: $vm.eventFilterState.selectedValue,
            width: 150
        )
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
    QuestView()
}
