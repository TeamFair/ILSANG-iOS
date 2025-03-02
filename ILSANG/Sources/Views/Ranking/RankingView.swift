//
//  RankingView.swift
//  ILSANG
//
//  Created by Kim Andrew on 10/7/24.
//

import SwiftUI

struct RankingView: View {
    
    @StateObject var vm = RankingViewModel(rankNetwork: RankNetwork())
    
    var body: some View {
        VStack (spacing: 0){
            headerView
            subHeaderView
            
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
        .task {
            await vm.loadRankIfNeeded(xpStat: vm.selectedXpStat)
        }
        .onChange(of: vm.selectedXpStat) { _, newValue in
            Task {
                await vm.loadRankIfNeeded(xpStat: newValue)
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
    }
    
    private var subHeaderView: some View {
        StatHeaderView(
            selectedXpStat: $vm.selectedXpStat,
            horizontalPadding: 0,
            height: 44,
            hasBottomLine: true
        )
    }
    
    private var rankingListView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                if let ranks = vm.userRank[vm.selectedXpStat] {
                    ForEach(Array(ranks.enumerated()), id: \.element.customerId) { idx, rank in
                        RankingItemView(idx: idx + 1, statRank: rank, style: .horizontal)
                    }
                }
            }
            .padding(.top, 24)
            .padding(.bottom, 72)
        }
        .animation(nil, value: vm.selectedXpStat)
        .refreshable {
            Task {
                await vm.fetchAndStoreUserRank(xpStat: vm.selectedXpStat)
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
            Task { await vm.loadRankIfNeeded(xpStat: vm.selectedXpStat) }
        }
    }
}

#Preview {
    RankingView()
}
