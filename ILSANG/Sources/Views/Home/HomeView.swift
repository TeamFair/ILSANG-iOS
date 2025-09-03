//
//  HomeView.swift
//  ILSANG
//
//  Created by Lee Jinhee on 12/21/24.
//

import SwiftUI

// TODO: 에러처리 재정의 필요
struct HomeView: View {
    @State var vm: HomeViewModel
    @StateObject var questRouter: QuestRouter
    @StateObject var userRouter: UserRouter
    @EnvironmentObject var dependencies: AppDependencies
    @EnvironmentObject var sharedState: SharedState
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
    
    init(
        vm: HomeViewModel,
        questRepository: QuestRepositoryInterface,
        illsangZoneManager: IllsangZoneManager
    ) {
        _vm = State(wrappedValue: vm)
        _questRouter = StateObject(
            wrappedValue: QuestRouter(
                illsangZoneManager: illsangZoneManager, questRepository: questRepository
            )
        )
        _userRouter = StateObject(wrappedValue: UserRouter())
    }
    
    var body: some View {
        Group {
            switch vm.viewStatus {
            case .loading, .loaded:
                ScrollView {
                    VStack(spacing: 0) {
                        header
                        content
                    }
                }
                .task {
                    // await honorAcquisitionManager.fetchUnreadHonorHistory()
                }
                .refreshable {
                    await vm.loadInitialData()
                }
                .disabled(vm.viewStatus == .loading)
                .withQuestNavigation(questRouter: questRouter)
                .withUserNavigation(userRouter: userRouter)
            case .error:
                networkErrorView
            }
        }
        .task {
            await vm.loadDataIfNeeded()
        }
        .background(Color.background)
        .overlay(
            Group {
                if let _ = dependencies.honorAcquisitionManager.currentHonor {
                    HonorPopupContainerView()
                } else if let alert = vm.alertType {
                     alertView(alert)
                }
            }
        )
       
        .navigationDestination(item: $vm.selectedBanner) { banner in
            BannerDetailView(
                viewModel: BannerDetailViewModel(
                    banner: banner,
                    userRepository: dependencies.userRepository,
                    questRepository: dependencies.questRepository,
                    areaRepository: dependencies.areaRepository,
                    favoriteService: dependencies.favoriteService
                )
            )
        }
        .navigationDestination(isPresented: $vm.showSelectMyRegionView) {
            MyRegionAreaSelectionView(areaRepository: dependencies.areaRepository) { area in
                vm.handleMyRegionSelection(area)
            }
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
        VStack(spacing: 0) {
            regionAndZoneSelectionView
            
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
//            .redacted(reason: vm.viewStatus == .loading ? .placeholder : [])
//            .foregroundStyle(redactionReasons.contains(.placeholder) ? .clear: Color.gray500)
        }
    }
    
    private var regionAndZoneSelectionView: some View {
        HStack(spacing: 4) {
            RegionPickerView(title: sharedState.selectedCommercialArea.areaName) {
                vm.showSelectMyRegionView = true
            }
            
            Spacer()
            Text("내 일상존: ")
                .styledFont(.caption2)
                .foregroundStyle(.gray400)
            Button {
                questRouter.handleIllsangZoneButtonTap()
            } label: {
                HStack(spacing: 0) {
                    Text(dependencies.illsangZoneManager.currentZoneName ?? "선택하기")
                        .styledFont(.caption1)
                    if dependencies.illsangZoneManager.currentZoneName == nil {
                        Image(.arrowUnder)
                            .resizable()
                            .scaledToFit()
                            .frame(16)
                            .rotationEffect(.degrees(-90))
                    }
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .roundedBackground(cornerRadius: 20, bgColor: .primaryPurple)
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, LayoutConstants.horizontalPadding)
    }
    
    private var mainBannerSection: some View {
        let height: CGFloat = .screenWidth / 3 * 2
        return TabView(selection: $vm.currentBanner) {
            ForEach(Array(vm.mainBanners.enumerated()), id: \.offset) { idx, item in
                if let bannerImage = item.image {
                    Image(uiImage: bannerImage)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: height)
                        .onTapGesture {
                            AnalyticsService.logEvent(.homeBannerClick(bannerId: item.id))
                            if let tab = vm.getTabFromURL(from: item.description) { /// 해당하는 탭으로 이동
                                sharedState.selectedTab = tab
                            } else {
                                vm.selectedBanner = item
                            }
                        }
                }
            }
        }
        .overlay(alignment: .bottomTrailing) {
            HStack(alignment: .center, spacing: 5) {
                Text("\(vm.currentBanner+1)")
                    .styledFont(.badge2)
                    .frame(minWidth: 7)
                    .foregroundStyle(.white)
                Rectangle()
                    .frame(width: 1, height: 8)
                Text("\(vm.mainBanners.count)")
                    .styledFont(.badge2)
                    .frame(minWidth: 7)
            }
            .foregroundStyle(.gray200)
            .padding(.vertical, 4)
            .padding(.horizontal, 10)
            .roundedBackground(cornerRadius: 20, bgColor: .black.opacity(0.7))
            .padding(20)
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
                PopularQuestItemView(
                    quest: quest,
                    imageSize: CGSize(width: (UIScreen.main.bounds.width - 40 - 2) / 2, height: 137)
                ) {
                    AnalyticsService.logEvent(.homePopularQuestClick(questId: quest.id))
                    questRouter.presentQuestDetail(quest: quest) { quest in
                        vm.toggleFavoriteStatus(quest: quest)
                    }
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
                            PopularQuestItemView(
                                quest: quest,
                                imageSize: CGSize(width: (UIScreen.main.bounds.width - 40 - 2) / 2, height: 137)
                            ) {
                                AnalyticsService.logEvent(.homePopularQuestClick(questId: quest.id))
                                questRouter.presentQuestDetail(quest: quest) { quest in
                                    vm.toggleFavoriteStatus(quest: quest)
                                }
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
                            RecommendQuestItemView(quest: quest) {
                                AnalyticsService.logEvent(.homeRecommendQuestClick(questId: quest.id))
                                questRouter.presentQuestDetail(quest: quest) { quest in
                                    vm.toggleFavoriteStatus(quest: quest)
                                }
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
                .label("더 많은 퀘스트 보기"),
                .bottom, {
                    sharedState.selectedTab = .quest /// 퀘스트 탭(선택된 스탯)으로 이동
                }
            ),
            content:
                Group {
                    ForEach(vm.largestRewardQuestList.prefix(3), id: \.id) { quest in
                        LargeRewardQuestItemView(quest: quest) {
                            AnalyticsService.logEvent(.homeBigRewardQuestClick(questId: quest.id))
                            questRouter.presentQuestDetail(quest: quest) { quest in
                                vm.toggleFavoriteStatus(quest: quest)
                            }
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
                        ForEach(vm.userRankList, id: \.userId) { rank in
                            Button {
                                AnalyticsService.logEvent(.homeRankingClick(userId: rank.userId))
                                userRouter.navigateToUserProfile(userId: rank.userId)
                            } label: {
                                RankingItemView(style: .totalRank(rank))
                            }
                        }
                    }
                    .padding(.horizontal, LayoutConstants.horizontalPadding)
                }
                .scrollIndicators(.never)
        )
    }
    
    @ViewBuilder
    private func alertView(_ alertType: AlertType) -> some View {
        if alertType ==  AlertType.myRegionChangeSuccess {
            SettingAlertView(
                alertType: alertType,
                onConfirm: { vm.alertType = nil }
            )
        }
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
        userRepository: UserRepository(network: UserNetwork()),
        areaNameService: AreaNameService(areaRepository: AreaRepository(network: AreaNetwork())),
        questRepository: QuestRepository(network: QuestNetwork()),
        rankRepository: RankRepository(network: RankNetwork()),
        bannerRepository: BannerRepository(network: BannerNetwork()),
        favoriteService: FavoriteService(favoriteNetwork: FavoriteNetwork()), sharedState: SharedState()
    )
    HomeView(
        vm: viewModel,
        questRepository: QuestRepository(network: QuestNetwork()),
        illsangZoneManager: IllsangZoneManager(
            areaNameService: AreaNameService(areaRepository: AreaRepository(network: AreaNetwork())),
            seasonManager: SeasonManager(seasonNetwork: SeasonNetwork())
        )
    )
}

extension Array {
    func chunks(of chunkSize: Int) -> [[Element]] {
        stride(from: 0, to: count, by: chunkSize).map {
            Array(self[$0..<Swift.min($0 + chunkSize, count)])
        }
    }
}
