//
//  RankingView.swift
//  ILSANG
//
//  Created by Kim Andrew on 10/7/24.
//

import SwiftUI

struct RankingView: View {
    @StateObject var vm: RankingViewModel
    @StateObject var userRouter: UserRouter
    @EnvironmentObject var dependencies: AppDependencies
    @EnvironmentObject var sharedState: SharedState
    @Environment(\.layout) var layout
    
    @State private var isRefreshing = false
   
    init(
        rankRepository: RankRepositoryInterface,
        areaNameService: AreaNameProvider,
        seasonManager: SeasonManager
    ) {
        _vm = StateObject(
            wrappedValue: RankingViewModel(
                rankRepository: rankRepository,
                areaNameService: areaNameService,
                seasonManager: seasonManager
            )
        )
        _userRouter = StateObject(wrappedValue: UserRouter())
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 94) // 고정 영역
            
            ScrollView {
                VStack(spacing: 0) {
                    if let currentSeason = vm.seasonManager.currentSeason {
                        seasonBannerView(season: currentSeason)
                    }
                    
                    LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                        Section(header: selectScopeView) {
                            switch vm.viewStatus {
                            case .loading:
                                ProgressView()
                                    .frame(height: 300)
                                    .frame(maxWidth: .infinity)
                            case .loaded:
                                rankingListView
                            case .error:
                                networkErrorView
                                    .frame(minHeight: 600, maxHeight: .infinity)
                            }
                        }
                        .background(Color.background)
                    }
                }
            }
            .scrollClipDisabled()
            .scrollDisabled(vm.viewStatus != .loaded)
            .refreshable {
                if isRefreshing || vm.viewStatus == .loading { return }
                isRefreshing = true
                defer { isRefreshing = false }
                await vm.loadRank(type: vm.selectedPointType)
            }
            .background(alignment: .top) {
                Color.white
                    .frame(height: 200)
            }
        }
        .withUserNavigation(userRouter: userRouter)
        .overlay(alignment: .bottom) {
            if let currentSeason = vm.seasonManager.currentSeason,
            let targetDate = currentSeason.endDate.toISO8601Date() {
                SeasonTimerView(season: currentSeason.seasonNumber, targetDate: targetDate)
                    .padding(.horizontal, layout.horizontalPadding)
                    .padding(.bottom, layout.horizontalPadding)
            }
        }
        .overlay {
            if vm.showSelectSeasonView {
                Color.black.opacity(0.5).ignoresSafeArea()
            }
        }
        .overlay(alignment: .top) {
            VStack(spacing: 0) {
                headerView
                selectSeasonView
            }
        }
        .background(Color.background)
        .task {
            await vm.loadRankIfNeeded(type: vm.selectedPointType)
        }
        .onChange(of: vm.selectedPointType) { _, newValue in
            Task {
                await vm.loadRankIfNeeded(type: vm.selectedPointType)
            }
        }
    }
}

extension RankingView {
    private var headerView: some View {
        Text("랭킹")
            .font(.system(size: 21, weight: .bold))
            .fontWeight(.bold)
            .foregroundColor(.gray500)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 50)
            .padding(.horizontal, layout.horizontalPadding)
            .background(Color.white)
    }
    
    private var selectSeasonView: some View {
        VStack(spacing: 0) {
            Button {
                vm.showSelectSeasonView.toggle()
            } label: {
                HStack(spacing: 4) {
                    if let seasonNumber = vm.selectedSeason?.seasonNumber {
                        Text("시즌 \(seasonNumber)")
                            .styledFont(.heading1)
                    } else {
                        Text("전체")
                            .styledFont(.heading1)
                    }
                    Image(.arrowRight)
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFit()
                        .frame(14)
                        .frame(19)
                        .rotationEffect(.degrees(90))
                }
                .foregroundStyle(.gray500)
                .frame(height: 44)
                .padding(.horizontal, layout.horizontalPadding)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
            
            if vm.showSelectSeasonView {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        Button {
                            vm.selectedSeason = nil
                            vm.showSelectSeasonView.toggle()
                            vm.reset()
                        } label: {
                            seasonListItemView(title: "전체")
                        }
                        ForEach(vm.seasons, id: \.id) { season in
                            Button {
                                vm.showSelectSeasonView.toggle()
                                vm.selectedSeason = season
                                vm.reset()
                            } label: {
                                seasonListItemView(title: "시즌 \(season.id)")
                            }
                        }
                    }
                    .padding(.horizontal, layout.horizontalPadding)
                }
                .frame(maxHeight: 170)
                .fixedSize(horizontal: false, vertical: true) // 콘텐츠 크기만큼 늘어나도록
                .background(.white)
                .cornerRadius(8, corners: [.bottomLeft, .bottomRight])
            }
        }
    }
    
    private func seasonListItemView(title: String) -> some View {
        Text(title)
            .styledFont(.subTitle1)
            .foregroundStyle(.gray500)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 56)
    }
    
    private func seasonBannerView(season: Season) -> some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                Text("일상 특별 시즌 \(season.seasonNumber)")
                    .font(.custom("payboocOTFExtraBold", size: 20))
                Text("\(season.startDate.formatDateOnly()) ~ \(season.endDate.formatDateOnly())")
                    .styledFont(.medium, size: 13, lineHeight: 17)
                    .foregroundStyle(.white.opacity(0.8))
                    .padding(.bottom, 5)
                HStack(spacing: 8) {
                    Button {
                        sharedState.selectedTab = .quest
                    } label: {
                        seasonBannerButtonView(title: "퀘스트 수행하기")
                    }
                    
                    NavigationLink {
                        RankingRewardView(
                            titleRepository: dependencies.titleRepository
                        )
                    } label: {
                        seasonBannerButtonView(title: "시즌 보상")
                    }
                }
            }
            .foregroundStyle(.white)
            
            Spacer(minLength: 0)
            
            Image(.treasure)
                .resizable()
                .scaledToFit()
                .frame(86)
        }
        .padding(20)
        .background(.primaryPurple)
        .cornerRadius(12)
        .padding(.horizontal, layout.horizontalPadding)
        .padding(.bottom, 24)
        .background(.white)
    }
    
    private func seasonBannerButtonView(title: String) -> some View {
        HStack(spacing: 4) {
            Text(title)
                .styledFont(.caption2)
            Image(.arrowRight)
                .resizable()
                .renderingMode(.template)
                .scaledToFit()
                .frame(8)
                .frame(16)
        }
        .padding(.vertical, 10)
        .padding(.leading, 12)
        .padding(.trailing, 8)
        .foregroundStyle(.white)
        .background(Color.primary500)
        .cornerRadius(30)
    }
    
    private var selectScopeView: some View {
        ScopeHeaderView(
            selectedScope: $vm.selectedPointType,
            horizontalPadding: 0,
            height: 44,
            hasBottomLine: true
        )
        .background(Color.white)
    }
    
    private var rankingListView: some View {
        LazyVStack(spacing: 12) {
            switch vm.selectedPointType {
            case .metro:
                ForEach(vm.metroRank) { rank in
                    Button {
                        vm.selectedRank = rank
                    } label: {
                        RankingItemView(style: .areaRank(rank))
                    }
                }
            case .commercial:
                ForEach(vm.commercialRank) { rank in
                    Button {
                        vm.selectedRank = rank
                    } label: {
                        RankingItemView(style: .areaRank(rank))
                    }
                }
            case .contribution:
                ForEach(vm.contributionRank, id: \.userId) { rank in
                    Button {
                        userRouter.navigateToUserProfile(userId: rank.userId)
//                        OtherUserProfileView(
//                            userId: rank.userId,
//                            userRepository: dependencies.userRepository,
//                            missionHistoryRepository: dependencies.missionHistoryRepository,
//                            areaNameService: dependencies.areaNameService,
//                            seasonManager: seasonManager
//                        )
                    } label: {
                        RankingItemView(style: .userRank(rank))
                    }
                }
            }
        }
        .padding(.top, 16)
        .padding(.bottom, 170)
        .background(Color.background)
        .animation(nil, value: vm.selectedPointType)
        .navigationDestination(item: $vm.selectedRank) { rank in
            switch vm.selectedPointType {
            case .metro:
                RankingDetailView(
                    vm: RankingDetailViewModel(
                        seasonId: vm.selectedSeasonId,
                        areaName: rank.areaName,
                        areaRank: rank.rank,
                        areaPoint: rank.point,
                        areaImageIds: rank.imageIds,
                        areaCode: rank.areaCode,
                        areaType: .metro,
                        rankRepository: dependencies.rankRepository,
                        areaNameService: dependencies.areaNameService
                    )
                )
            case .commercial:
                RankingDetailView(
                    vm: RankingDetailViewModel(
                        seasonId: vm.selectedSeasonId,
                        areaName: rank.areaName,
                        areaRank: rank.rank,
                        areaPoint: rank.point,
                        areaImageIds: rank.imageIds,
                        areaCode: rank.areaCode,
                        areaType: .commercial,
                        rankRepository: dependencies.rankRepository,
                        areaNameService: dependencies.areaNameService
                    )
                )
            case .contribution:
                EmptyView()
            }
        }
    }
    
    private var networkErrorView: some View {
        ErrorView(
            systemImageName: "wifi.exclamationmark",
            title: "네트워크 연결 상태를 확인해주세요",
            subTitle: "네트워크 연결 상태가 좋지 않아\n랭킹을 불러올 수 없어요",
            emoticon: "🥲"
        ) {
            Task { await vm.loadRank(type: vm.selectedPointType) }
        }
    }
}

#Preview {
    RankingView(
        rankRepository: RankRepository(network: RankNetwork()),
        areaNameService: AreaNameService(areaRepository: AreaRepository(network: AreaNetwork())),
        seasonManager: SeasonManager(
            seasonNetwork: SeasonNetwork()
        )
    )
}
