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
   
    var homeViewModel: HomeViewModel
    @StateObject var questViewModel: QuestViewModel
    
    static var defaultHonorNetwork: HonorNetworkProtocol {
        return HonorNetwork() // MockHonorNetwork()
    }
    
    static var defaultSeasonNetwork: SeasonNetworkProtocol {
        return SeasonNetwork() // MockSeasonNetwork()
    }
    
    init() {
        let sharedState = SharedState()
        _sharedState = StateObject(wrappedValue: sharedState)
        
        self.homeViewModel =  HomeViewModel(
            questRepository: QuestRepository(network: QuestNetwork()),
            rankNetwork: RankNetwork(),
            bannerNetwork: BannerNetwork(),
            favoriteService: FavoriteService(favoriteNetwork: FavoriteNetwork()),
            sharedState: sharedState
        )
        
#if DEBUG
           self._questViewModel = StateObject(wrappedValue: QuestViewModel(
            questRepository: MockQuestRepository(),
            favoriteService: FavoriteService(favoriteNetwork: FavoriteNetwork()), sharedState: sharedState)
           )
           
#else
           self._questViewModel = StateObject(wrappedValue: QuestViewModel(
            questRepository: QuestRepository(network: QuestNetwork()),
            favoriteService: FavoriteService(favoriteNetwork: FavoriteNetwork()), sharedState: sharedState)
           )
#endif
          
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
            HomeView(vm: homeViewModel)
        case .quest:
            QuestView(vm: questViewModel)
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
    @Published var selectedCommercialArea: CommercialArea {
        didSet {
            UserDefaults.standard.saveCommercialArea(selectedCommercialArea)
        }
    }
    
    init() {
        self.selectedCommercialArea = UserDefaults.standard.loadCommercialArea()
        ?? CommercialArea(code: "R100", areaName: "서현", description: "", metroAreaCode: "G01")
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
