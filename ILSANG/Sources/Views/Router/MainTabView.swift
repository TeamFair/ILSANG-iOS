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
    @StateObject var seasonManager: SeasonManager

    @State var homeViewModel: HomeViewModel
    @StateObject var questViewModel: QuestViewModel
    var approvalViewModel: ApprovalViewModel
    @StateObject var rankViewModel: RankingViewModel
    @StateObject var myPageViewModel: MyPageViewModel
    
    static var defaultHonorNetwork: HonorNetworkProtocol {
        return HonorNetwork() // MockHonorNetwork()
    }
    
    static var defaultSeasonNetwork: SeasonNetworkProtocol {
        return SeasonNetwork() // MockSeasonNetwork()
    }
    
    init() {
        let sharedState = SharedState()
        _sharedState = StateObject(wrappedValue: sharedState)
        
        let seasonManager = SeasonManager(seasonNetwork: MainTabView.defaultSeasonNetwork)
        _seasonManager = StateObject(wrappedValue: seasonManager)
        
        let userNetwork = UserNetwork()
        let userRepository = UserRepository(network: userNetwork)
        let rankRepository = RankRepository(network: RankNetwork())
        let areaRepository = AreaRepository(network: AreaNetwork())
        let areaNameService = AreaNameService(areaRepository: areaRepository)

        self._homeViewModel = State(wrappedValue: HomeViewModel(
            userRepository: userRepository,
            areaNameService: areaNameService,
            questRepository: QuestRepository(network: QuestNetwork()),
            rankRepository: rankRepository,
            bannerRepository: BannerRepository(network: BannerNetwork()),
            areaRepository: areaRepository,
            favoriteService: FavoriteService(favoriteNetwork: FavoriteNetwork()),
            sharedState: sharedState
        ))
        
//#if DEBUG
//           self._questViewModel = StateObject(wrappedValue: QuestViewModel(
//            questRepository: MockQuestRepository(),
//            areaRepository: areaRepository,
//            favoriteService: FavoriteService(favoriteNetwork: FavoriteNetwork()), sharedState: sharedState)
//           )
//           
//#else
           self._questViewModel = StateObject(wrappedValue: QuestViewModel(
            questRepository: QuestRepository(network: QuestNetwork()),
            areaRepository: areaRepository,
            favoriteService: FavoriteService(favoriteNetwork: FavoriteNetwork()), sharedState: sharedState)
           )
//#endif
        self.approvalViewModel = ApprovalViewModel(
            emojiNetwork: EmojiNetwork(),
            userRepository: userRepository,
            missionHistoryRepository: MissionHistoryRepository(network: MissionHistoryNetwork()),
            areaNameService: areaNameService
        )
        
        self._rankViewModel = StateObject(
            wrappedValue:
                RankingViewModel(
                    rankRepository: rankRepository,
                    userRepository: userRepository,
                    areaNameService: areaNameService,
                    seasonManager: seasonManager
                )
        )
        
        self._myPageViewModel = StateObject(
            wrappedValue: MyPageViewModel(
                userRepository: userRepository,
                imageNetwork: ImageNetwork(),
                areaNameService: AreaNameService(areaRepository: AreaRepository(network: AreaNetwork())),
                seasonManager: seasonManager
            )
        )
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
            ApprovalView(vm: approvalViewModel)
        case .ranking:
            RankingView(vm: rankViewModel)
        case .mypage:
            MyPageView(vm: myPageViewModel)
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
