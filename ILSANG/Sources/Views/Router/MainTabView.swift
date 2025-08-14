//
//  MainTabView.swift
//  ILSANG
//
//  Created by Lee Jinhee on 5/20/24.
//

import SwiftUI

struct MainTabView: View {
    @StateObject var sharedState = SharedState()
    @StateObject var honorAcquisitionManager = HonorAcquisitionManager(honorNetwork: defaultHonorNetwork)
    @StateObject var seasonManager = SeasonManager(seasonNetwork: defaultSeasonNetwork)
    let viewModel = HomeViewModel(
        questNetwork: QuestNetwork(),
        rankNetwork: RankNetwork(),
        bannerNetwork: BannerNetwork(),
        favoriteService: FavoriteService(favoriteNetwork: FavoriteNetwork())
    )
    
    static var defaultHonorNetwork: HonorNetworkProtocol {
        return HonorNetwork() // MockHonorNetwork()
    }
    
    static var defaultSeasonNetwork: SeasonNetworkProtocol {
        return SeasonNetwork() // MockSeasonNetwork()
    }
    
    var body: some View {
        NavigationStack {
            TabView(selection: $sharedState.selectedTab) {
                ForEach(Tab.allCases, id: \.self) { tab in
                    createTabView(for: tab)
                        .tabItem {
                            Image(tab == sharedState.selectedTab ? tab.selectedIcon: tab.icon)
                            Text(tab.title)
                        }
                        .tag(tab)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .onChange(of: sharedState.selectedTab) { _, newTab in
                AnalyticsService.logEvent(.bottomTabClick(tabName: sharedState.selectedTab.rawValue.uppercased()))
            }
            .overlay(
                Group {
                    SeasonPopupContainerView {
                        sharedState.selectedTab = .ranking
                    }
                }
            )
        }
        .environmentObject(sharedState)
        .environmentObject(honorAcquisitionManager)
        .environmentObject(seasonManager)
    }
    
    @ViewBuilder
    func createTabView(for tab: Tab) -> some View {
        switch tab {
        case .home:
            HomeView(vm: viewModel)
        case .quest:
            QuestView(initialXpStat: sharedState.selectedXpStat)
        case .approval:
            ApprovalView()
        case .ranking:
            RankingView()
        case .mypage:
            MyPageView()
        }
    }
}

class SharedState: ObservableObject {
    @Published var selectedTab: Tab = .home
    @Published var selectedXpStat: XpStat = .strength
}
