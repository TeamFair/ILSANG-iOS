//
//  MainTabView.swift
//  ILSANG
//
//  Created by Lee Jinhee on 5/20/24.
//

import SwiftUI

struct MainTabView: View {
    @StateObject var sharedState = SharedState()

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
            .environmentObject(sharedState) // 뷰 모델 전달
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
        }
    }
    
    @ViewBuilder
    func createTabView(for tab: Tab) -> some View {
        switch tab {
        case .home:
            HomeView()
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
