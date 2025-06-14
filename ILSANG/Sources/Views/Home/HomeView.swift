//
//  HomeView.swift
//  ILSANG
//
//  Created by Lee Jinhee on 12/21/24.
//

import SwiftUI

// TODO: 에러처리 재정의 필요
struct HomeView: View {
    @Bindable var vm: HomeViewModel
    @EnvironmentObject var sharedState: SharedState
    @EnvironmentObject var honorAcquisitionManager: HonorAcquisitionManager
    @Environment(\.redactionReasons) var redactionReasons
    
    private let gridItem = [GridItem(), GridItem()]
    
    private struct LayoutConstants {
        static let sectionSpacing: CGFloat = 36
        static let vStackSpacing: CGFloat = 26
        static let lazyHGridSpacing: CGFloat = 9
        static let horizontalPadding: CGFloat = 20
        static let tabViewHeight: CGFloat = 450
        static let paginationSpacing: CGFloat = 4
        static let circleSize: CGFloat = 10
    }
    
    var body: some View {
        NavigationStack {
            switch vm.viewStatus {
            case .loading, .loaded:
                ScrollView {
                    VStack(spacing: 23) {
                        header
                        content
                    }
                }
                .task {
                    await honorAcquisitionManager.fetchUnreadHonorHistory()
                }
                .refreshable {
                    Task {
                        await vm.loadInitialData()
                    }
                }
                .disabled(vm.viewStatus == .loading)
            case .error:
                networkErrorView
            }
        }
        .background(Color.background)
        .overlay(
            Group {
                if let _ = honorAcquisitionManager.currentHonor {
                    HonorPopupContainerView()
                }
            }
        )
        .sheet(isPresented: $vm.showQuestSheet) {
            let tall = vm.selectedQuest.isRepeatQuest || vm.selectedQuest.missionType == .image
            QuestDetailView(
                vm: QuestDetailViewModel(
                    quest: vm.selectedQuest,
                    questNetwork: QuestNetwork(),
                    onUpdate: { quest in
                        vm.toggleFavoriteStatus(quest: quest)
                    }
                )
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
            QuestEngageView(
                vm: QuestEngageViewModel(
                    quest: vm.selectedQuest,
                    quizNetwork: QuizNetwork()
                ),
                submitVM: SubmitRouterViewModel(
                    selectedImage: nil,
                    selectedQuest: vm.selectedQuest,
                    submitService: ImageChallengeSubmitService(imageNetwork: ImageNetwork(), challengeNetwork: ChallengeNetwork()),
                    quizNetwork: QuizNetwork()
                )
            )
        }
    }
    
    private var header: some View {
        HStack(alignment: .bottom) {
            Image(.logoWithAlpha)
                .frame(maxWidth: .infinity, alignment: .leading)
            Button {
                sharedState.selectedTab = .mypage /// 마이 탭으로 이동
            } label: {
                Image(uiImage: vm.userProfileImage ?? .profileCircle)
                    .resizable()
                    .frame(width: 36, height: 36)
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, LayoutConstants.horizontalPadding)
    }
    
    private var content: some View {
        LazyVStack(spacing: LayoutConstants.sectionSpacing) {
            if vm.showMainBanners {
                mainBannerSection
            }
            if vm.showPopularRewardQuest {
                popularQuestSection
            }
            if vm.showRecommendRewardQuest {
                recommendQuestSection
            }
            if vm.showLargestRewardQuest {
                largestRewardQuestSection
            }
            if vm.showRankList {
                userRankingSection
            }
        }
        .padding(.bottom, 72)
        .redacted(reason: vm.viewStatus == .loading ? .placeholder : [])
        .foregroundStyle(redactionReasons.contains(.placeholder) ? .clear: Color.gray500)
    }
    
    private var mainBannerSection: some View {
        let height: CGFloat = .screenWidth / 11 * 10
        return TabView {
            ForEach(Array(vm.mainBanners.enumerated()), id: \.offset) { idx, item in
                if let bannerImage = item.image {
                    Image(uiImage: bannerImage)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: height)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .onTapGesture {
                            AnalyticsService.logEvent(.homeBannerClick(bannerId: item.id))
                            if let tab = vm.getTabFromURL(from: item.description) { /// 해당하는 탭으로 이동
                                sharedState.selectedTab = tab
                            }
                        }
                }
            }
        }
        .frame(height: height)
        .tabViewStyle(.page(indexDisplayMode: .never))
    }
    
    private var popularQuestSection: some View {
        TitleWithContentView(
            title: "이번 달 인기 퀘스트 모음",
            content: popularQuestSectionContent
        )
    }
    
    @ViewBuilder
    private var popularQuestSectionContent: some View {
        if vm.popularQuestList.count <= vm.popularChunkSize {
            singlePageContent
        } else {
            multiPageContent
        }
    }
    
    private var singlePageContent: some View {
        LazyHGrid(rows: gridItem, alignment: .top, spacing: LayoutConstants.lazyHGridSpacing) {
            ForEach(vm.popularQuestList) { quest in
                QuestItemView(
                    quest: quest,
                    style: PopularStyle(type: quest.type, repeatType: RepeatType(rawValue: quest.target.lowercased()) ?? .daily),
                    tagTitle: "\(quest.totalRewardXP())XP"
                ) {
                    AnalyticsService.logEvent(.homePopularQuestClick(questId: quest.id))
                    vm.onQuestTapped(quest: quest)
                }
            }
        }
        .padding(.horizontal, LayoutConstants.horizontalPadding)
    }
    
    private var multiPageContent: some View {
        VStack(spacing: LayoutConstants.vStackSpacing) {
            TabView(selection: $vm.selectedPopularTabIndex) {
                ForEach(vm.paginatedPopularQuests.indices, id: \.self) { pageIndex in
                    LazyHGrid(rows: gridItem, alignment: .top, spacing: LayoutConstants.lazyHGridSpacing) {
                        ForEach(vm.paginatedPopularQuests[pageIndex]) { quest in
                            QuestItemView(
                                quest: quest,
                                style: PopularStyle(type: quest.type, repeatType: RepeatType(rawValue: quest.target.lowercased()) ?? .daily),
                                tagTitle: "\(quest.totalRewardXP())XP"
                            ) {
                                AnalyticsService.logEvent(.homePopularQuestClick(questId: quest.id))
                                vm.onQuestTapped(quest: quest)
                            }
                        }
                    }
                    .padding(.horizontal, LayoutConstants.horizontalPadding)
                    .tag(pageIndex)
                }
            }
            .frame(height: LayoutConstants.tabViewHeight)
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            paginationIndicator
        }
    }
    
    private var paginationIndicator: some View {
        HStack(spacing: LayoutConstants.paginationSpacing) {
            let pageCount = Int(vm.popularQuestList.count / vm.popularChunkSize)
            if pageCount >= 2 {
                ForEach(0..<pageCount, id: \.self) { index in
                    Circle()
                        .frame(width: LayoutConstants.circleSize, height: LayoutConstants.circleSize)
                        .foregroundStyle(index == vm.selectedPopularTabIndex ? Color.gray500 : Color.gray100)
                        .animation(.default, value: index)
                }
            }
        }
    }
    
    private var recommendQuestSection: some View {
        TitleWithContentView(
            title: vm.recommendQuestTitle,
            content:
                ScrollView(.horizontal) {
                    HStack(spacing: 12) {
                        ForEach(vm.recommendQuestList, id: \.id) { quest in
                            QuestItemView(
                                quest: quest,
                                style: RecommendStyle()
                            ) {
                                AnalyticsService.logEvent(.homeRecommendQuestClick(questId: quest.id))
                                vm.onQuestTapped(quest: quest)
                            }
                        }
                    }
                    .padding(.horizontal, LayoutConstants.horizontalPadding)
                }
                .scrollIndicators(.hidden)
        )
    }
    
    private var largestRewardQuestSection: some View {
        TitleWithContentView(
            title: "큰 보상 퀘스트",
            seeAll: (
                .label("전체 보기"),
                .bottomTrailing, {
                    sharedState.selectedXpStat = vm.selectedXpStat
                    sharedState.selectedTab = .quest /// 퀘스트 탭(선택된 스탯)으로 이동
                }
            ),
            content:
                Group {
                    StatHeaderView(
                        selectedXpStat: $vm.selectedXpStat,
                        horizontalPadding: LayoutConstants.horizontalPadding,
                        height: 30,
                        hasBottomLine: false
                    )
                    // TODO: (디자인 대기 중) 퀘스트 타입에 따라 다르게 보여줘야함
                    ForEach(vm.largestRewardQuestList[vm.selectedXpStat, default: []].prefix(3), id: \.id) { quest in
                        QuestItemView(
                            quest: quest,
                            style: UncompletedStyle(),
                            tagTitle: String(quest.totalRewardXP())+"XP"
                        ) {
                            vm.toggleFavoriteStatus(quest: quest)
                        } action: {
                            AnalyticsService.logEvent(.homeBigRewardQuestClick(questId: quest.id, stat: vm.selectedXpStat.parameterText))
                            vm.onQuestTapped(quest: quest)
                        }
                    }
                }
        )
    }
    
    private var userRankingSection: some View {
        TitleWithContentView(
            title: "유저 랭킹",
            seeAll: (
                .icon,
                .topTrailing, {
                    sharedState.selectedTab = .ranking /// 랭킹탭 이동
                }
            ),
            content:
                ScrollView(.horizontal) {
                    HStack(spacing: 8) {
                        ForEach(Array(vm.userRankList.enumerated()), id: \.offset) { idx, rank in
                            Button {
                                AnalyticsService.logEvent(.homeRankingClick(userId: rank.customerId))
                                vm.selectedCustomerId = rank.customerId
                                vm.showOtherUserProfileView = true
                            } label: {
                                RankingItemView(rank: rank.toRank(), style: .vertical)
                            }
                        }
                    }
                    .padding(.horizontal, LayoutConstants.horizontalPadding)
                }
                .scrollIndicators(.never)
                .navigationDestination(isPresented: $vm.showOtherUserProfileView) {
                    if let customerId = vm.selectedCustomerId {
                        OtherUserProfileView(customerId: customerId)
                    }
                }
        )
    }
    
    private var networkErrorView: some View {
        ErrorView(
            systemImageName: "wifi.exclamationmark",
            title: "네트워크 연결 상태를 확인해주세요",
            subTitle: "네트워크 연결 상태가 좋지 않아\n정보를 불러올 수 없어요 ",
            emoticon: "🥲"
        ) {
            Task { await vm.loadInitialData() }
        }
    }
}

#Preview {
    let viewModel = HomeViewModel(
        questNetwork: QuestNetwork(),
        rankNetwork: RankNetwork(),
        bannerNetwork: BannerNetwork(),
        favoriteService: FavoriteService(favoriteNetwork: FavoriteNetwork())
    )
    HomeView(vm: viewModel)
}

extension Array {
    func chunks(of chunkSize: Int) -> [[Element]] {
        stride(from: 0, to: count, by: chunkSize).map {
            Array(self[$0..<Swift.min($0 + chunkSize, count)])
        }
    }
}
