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
    @Published var selectedPointType: PointType = .metro
    @Published var userRank: [PointType: [StatRankViewModelItem]] = Dictionary(uniqueKeysWithValues: PointType.allCases.map { ($0, []) })
    
    private let rankNetwork: RankNetwork
    
    init(rankNetwork: RankNetwork)  {
        self.rankNetwork = rankNetwork
    }
    
    func loadRankIfNeeded(type: PointType) async {
        if let users = userRank[type], users.count > 0 {
            return
        }
        await fetchAndStoreUserRank(type: type)
    }
    
    @MainActor
    func fetchAndStoreUserRank(type: PointType) async {
//        changeViewStatus(.loading)
//        let res = await rankNetwork.getRankByStat(xpstat: xpStat.parameterText)
//        
//        switch res {
//        case .success(let response):
//            let items = await withTaskGroup(of: (Int, StatRankViewModelItem).self) { group in
//                for (index, rank) in response.data.enumerated() {
//                    group.addTask {
//                        let item = await StatRankViewModelItem(rank: rank)
//                        return (index, item)
//                    }
//                }
//                
//                var results = Array<StatRankViewModelItem?>(repeating: nil, count: response.data.count)
//                for await (index, item) in group {
//                    results[index] = item
//                }
//                
//                return results.compactMap { $0 } // nil 제거
//            }
//            self.userRank[xpStat] = items
//            changeViewStatus(.loaded)
//        case .failure:
//            changeViewStatus(.error)
//            Log(res)
//        }
    }
    
    @MainActor
    func changeViewStatus(_ viewStatus: ViewStatus) {
        self.viewStatus = viewStatus
    }
}

import UIKit

struct StatRankViewModelItem {
    let xpType: String
    let xpPoint: Int
    let xpTotalPoint: Int
    let title: Title?
    let customerId: String
    let nickname: String
    let profileImageId: String?
    let profileImage: UIImage?
    
    init(xpType: String, xpPoint: Int, xpTotalPoint: Int, title: Title?, customerId: String, nickname: String, profileImageId: String?, profileImage: UIImage?) {
        self.xpType = xpType
        self.xpPoint = xpPoint
        self.xpTotalPoint = xpTotalPoint
        self.title = title
        self.customerId = customerId
        self.nickname = nickname
        self.profileImageId = profileImageId
        self.profileImage = profileImage
    }
    
    init(rank: StatRank) async {
        self.xpType = rank.xpType
        self.xpPoint = rank.xpPoint
        self.xpTotalPoint = rank.xpTotalPoint
        self.title = rank.title
        self.customerId = rank.customerId
        self.nickname = rank.nickname
        self.profileImageId = rank.profileImageId
        self.profileImage = await ImageCacheService.shared.loadImageAsync(imageId: rank.profileImageId ?? "")
    }
}
