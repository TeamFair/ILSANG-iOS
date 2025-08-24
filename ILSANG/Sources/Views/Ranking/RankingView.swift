//
//  RankingView.swift
//  ILSANG
//
//  Created by Kim Andrew on 10/7/24.
//

import SwiftUI

struct RankingView: View {
    @StateObject var vm = RankingViewModel(rankNetwork: RankNetwork())
    @EnvironmentObject var sharedState: SharedState
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 94) // 고정 영역
            
            ScrollView {
                VStack(spacing: 0) {
                    seasonBannerView
                    
                    LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                        Section(header: selectScopeView) {
                            switch vm.viewStatus {
                            case .loading:
                                ProgressView().frame(maxHeight: .infinity)
                            case .loaded:
                                rankingListView
                            case .error:
                                networkErrorView
                            }
                        }
                        .background(Color.background)
                    }
                }
            }
            .background(alignment: .top) {
                Color.white
                    .frame(height: 400)
            }
            .background(alignment: .bottom) {
                Color.background
                    .frame(height: 200)
            }
        }
        .overlay(alignment: .bottom) {
            SeasonTimerView(season: 1, targetDateString: "2025-09-01")
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
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
            await vm.loadRankIfNeeded(scope: vm.selectedPointType)
        }
        .onChange(of: vm.selectedPointType) { _, newValue in
            Task {
                await vm.loadRankIfNeeded(scope: newValue)
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
            .padding(.horizontal, 20)
            .background(Color.white)
    }
    
    private var selectSeasonView: some View {
        VStack(spacing: 0) {
            Button {
                vm.showSelectSeasonView.toggle()
            } label: {
                HStack(spacing: 4) {
                    Text("시즌 1")
                        .styledFont(.heading1)
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
                .padding(.horizontal, 20)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
            
            if vm.showSelectSeasonView {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        Button {
                            // TODO: 전체 시즌 데이터 불러오기
                            vm.showSelectSeasonView.toggle()
                        } label: {
                            seasonListItemView(title: "전체")
                        }
                        ForEach(1..<3) { i in // TODO: 시즌 데이터 연결
                            Button {
                                // TODO: 해당 시즌 데이터 불러오기
                                vm.showSelectSeasonView.toggle()
                            } label: {
                                seasonListItemView(title: "시즌 \(i)")
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .background(Color.white)
                }
                .frame(maxHeight: 170)
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
    
    private var seasonBannerView: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                Text("일상 특별 시즌 1")
                    .font(.custom("payboocOTFExtraBold", size: 20))
                Text("2025.05.04~2025.05.20")
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
                        RankingRewardView()
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
        .padding(.horizontal)
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
        ScrollView {
            LazyVStack(spacing: 12) {
                if let ranks = vm.userRank[vm.selectedPointType] {
                    ForEach(Array(ranks.enumerated()), id: \.element.customerId) { idx, rank in
                        switch vm.selectedPointType {
                        case .metro, .commercial:
                            NavigationLink {
                                // TODO: 데이터 연결
                                RankingDetailView(vm: RankingDetailViewModel())
                            } label: {
                                RankingItemView(rank: rank.toRank(idx: idx+1), style: .horizontal(case: .locationPoint))
                            }
                        case .contribution:
                            NavigationLink {
                                OtherUserProfileView(customerId: rank.customerId)
                            } label: {
                                RankingItemView(rank: rank.toRank(idx: idx+1), style: .horizontal(case: .userPoint))
                            }
                        }
                    }
                }
            }
            .padding(.top, 16)
            .padding(.bottom, 120)
        }
        .background(Color.background)
        .animation(nil, value: vm.selectedPointType)
        .refreshable {
            Task {
                await vm.fetchAndStoreUserRank(scope: vm.selectedPointType)
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
            Task { await vm.loadRankIfNeeded(scope: vm.selectedPointType) }
        }
    }
}

#Preview {
    RankingView()
}
