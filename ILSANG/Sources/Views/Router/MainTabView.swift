//
//  MainTabView.swift
//  ILSANG
//
//  Created by Lee Jinhee on 5/20/24.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var dependencies: AppDependencies
    @EnvironmentObject var sharedState: SharedState
    
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
    }
    
    @ViewBuilder
    func createTabView(for tab: Tab) -> some View {
        switch tab {
        case .home:
            HomeView(
                vm: HomeViewModel(
                    userRepository: dependencies.userRepository,
                    areaNameService: dependencies.areaNameService,
                    questRepository: dependencies.questRepository,
                    rankRepository: dependencies.rankRepository,
                    bannerRepository: dependencies.bannerRepository,
                    favoriteService: dependencies.favoriteService,
                    sharedState: sharedState
                ),
                questRepository: dependencies.questRepository,
                illsangZoneManager: dependencies.illsangZoneManager
            )
            
        case .quest:
            QuestView(
                vm: QuestViewModel(
                    questRepository: dependencies.questRepository,
                    favoriteService: dependencies.favoriteService,
                    sharedState: sharedState
                ),
                questRepository: dependencies.questRepository,
                illsangZoneManager: dependencies.illsangZoneManager
            )
            
        case .approval:
            ApprovalView(
                vm: ApprovalViewModel(
                    approvalSource: .tab,
                    emojiNetwork: dependencies.emojiNetwork,
                    missionHistoryRepository: dependencies.missionHistoryRepository,
                    areaNameService: dependencies.areaNameService
                )
            )
            
        case .ranking:
            RankingView(
                vm: RankingViewModel(
                    rankRepository: dependencies.rankRepository,
                    areaNameService: dependencies.areaNameService,
                    seasonManager: dependencies.seasonManager
                )
            )
            
        case .mypage:
            MyPageView(
                vm: MyPageViewModel(
                    userRepository: dependencies.userRepository,
                    imageNetwork: dependencies.imageNetwork,
                    areaNameService: dependencies.areaNameService,
                    seasonManager: dependencies.seasonManager
                )
            )
        }
    }
}

class SharedState: ObservableObject {
    @Published var selectedTab: Tab = .home
    @Published var selectedCommercialArea: CommercialArea {
        didSet {
            UserDefaults.standard.saveCommercialArea(selectedCommercialArea)
        }
    }
    
    init() {
        self.selectedCommercialArea = UserDefaults.standard.loadCommercialArea()
        ?? CommercialArea(code: "R100", areaName: "서현", metroAreaCode: "G01")
    }
}

extension UserDefaults {
    private enum Keys {
        static let selectedCommercialArea = "selectedCommercialArea"
    }

    func saveCommercialArea(_ area: CommercialArea) {
        if let data = try? JSONEncoder().encode(area) {
            set(data, forKey: Keys.selectedCommercialArea)
        }
    }

    func loadCommercialArea() -> CommercialArea? {
        guard let data = data(forKey: Keys.selectedCommercialArea),
              let area = try? JSONDecoder().decode(CommercialArea.self, from: data) else {
            return nil
        }
        return area
    }
}
