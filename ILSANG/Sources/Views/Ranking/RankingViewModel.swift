//
//  RankingViewModel.swift
//  ILSANG
//
//  Created by Kim Andrew on 10/7/24.
//

import Foundation

// [데이터 로드 방식]
// 초기화될 때, 초기 스탯에 대한 랭킹 불러옴
// 선택된 스탯이 변경되면, 불러왔던 데이터가 있는지 확인한 후 랭킹 데이터 불러옴
class RankingViewModel: ObservableObject {
    enum ViewStatus {
        case error
        case loading
        case loaded
    }
    
    @Published var viewStatus: ViewStatus = .loading
    @Published var selectedXpStat: XpStat = .strength
    @Published var userRank: [XpStat: [StatRank]] = Dictionary(uniqueKeysWithValues: XpStat.allCases.map { ($0, []) })
    
    private let rankNetwork: RankNetwork
    
    init(rankNetwork: RankNetwork)  {
        self.rankNetwork = rankNetwork
    }
    
    func loadRankIfNeeded(xpStat: XpStat) async {
        if let users = userRank[xpStat], users.count > 0 {
            return
        }
        await fetchAndStoreUserRank(xpStat: xpStat)
    }
    
    @MainActor
    func fetchAndStoreUserRank(xpStat: XpStat) async {
        changeViewStatus(.loading)
        let res = await rankNetwork.getRankByStat(xpstat: xpStat.parameterText)
        
        switch res {
        case .success(let response):
            self.userRank[xpStat] = response.data
            changeViewStatus(.loaded)
        case .failure:
            changeViewStatus(.error)
            Log(res)
        }
    }
    
    @MainActor
    func changeViewStatus(_ viewStatus: ViewStatus) {
        self.viewStatus = viewStatus
    }
}

