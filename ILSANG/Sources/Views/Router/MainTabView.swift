//
//  MainTabView.swift
//  ILSANG
//
//  Created by Lee Jinhee on 5/20/24.
//

import SwiftUI

struct MainTabView: View {
    @StateObject var dependencies = AppDependencies()
    @StateObject var sharedState = SharedState()
    @StateObject var honorAcquisitionManager = HonorAcquisitionManager(honorNetwork: defaultHonorNetwork)
    @StateObject var seasonManager: SeasonManager // TODO: AppDependencies에 통합

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
        let dependencies = AppDependencies()
        _dependencies = StateObject(wrappedValue: dependencies)
        
        let sharedState = SharedState()
        _sharedState = StateObject(wrappedValue: sharedState)
        
        let seasonManager = SeasonManager(seasonNetwork: MainTabView.defaultSeasonNetwork)
        _seasonManager = StateObject(wrappedValue: seasonManager)
        
        self._homeViewModel = State(wrappedValue: HomeViewModel(
            userRepository: dependencies.userRepository,
            areaNameService: dependencies.areaNameService,
            questRepository: dependencies.questRepository,
            rankRepository: dependencies.rankRepository,
            bannerRepository: dependencies.bannerRepository,
            areaRepository: dependencies.areaRepository,
            favoriteService: dependencies.favoriteService,
            sharedState: sharedState
        ))
        
        self._questViewModel = StateObject(wrappedValue: QuestViewModel(
            questRepository: dependencies.questRepository,
            areaRepository: dependencies.areaRepository,
            favoriteService: dependencies.favoriteService,
            sharedState: sharedState
        ))
        
        self.approvalViewModel = ApprovalViewModel(
            approvalSource: .tab,
            emojiNetwork: dependencies.emojiNetwork,
            userRepository: dependencies.userRepository,
            missionHistoryRepository: dependencies.missionHistoryRepository,
            areaNameService: dependencies.areaNameService
        )
        
        self._rankViewModel = StateObject(
            wrappedValue:
                RankingViewModel(
                    rankRepository: dependencies.rankRepository,
                    userRepository: dependencies.userRepository,
                    areaNameService: dependencies.areaNameService,
                    seasonManager: seasonManager
                )
        )
        
        self._myPageViewModel = StateObject(
            wrappedValue: MyPageViewModel(
                userRepository: dependencies.userRepository,
                imageNetwork: dependencies.imageNetwork,
                areaNameService: dependencies.areaNameService,
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
        .environmentObject(dependencies)
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
