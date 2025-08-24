//
//  RankingViewModel.swift
//  ILSANG
//
//  Created by Kim Andrew on 10/7/24.
//

import Foundation

class RankingViewModel: ObservableObject {
    enum ViewStatus {
        case error
        case loading
        case loaded
    }
    
    @Published var viewStatus: ViewStatus = .loaded // 변경
    @Published var selectedPointType: PointType = .metro
    @Published var showSelectSeasonView = false

    @Published var userRank: [PointType: [StatRankViewModelItem]] = Dictionary(uniqueKeysWithValues: PointType.allCases.map { ($0, []) })
    
    private let rankNetwork: RankNetwork
    
    init(rankNetwork: RankNetwork)  {
        self.rankNetwork = rankNetwork
    }
    
    func loadRankIfNeeded(scope: PointType) async {
        if let users = userRank[scope], users.count > 0 {
            return
        }
        await fetchAndStoreUserRank(scope: scope)
    }
    
    @MainActor
    func fetchAndStoreUserRank(scope: PointType) async {
        // 변경
        userRank[.contribution]?.append(
            .init(
                xpPoint: 10,
                xpTotalPoint: 100,
                title: .mockLegend,
                customerId: "112333",
                nickname: "유저124",
                profileImageId: "",
                profileImage: nil
            )
        )
        userRank[.commercial]?.append(
            .init(
                xpPoint: 10,
                xpTotalPoint: 100,
                title: .mockLegend,
                customerId: "133",
                nickname: "유저124",
                profileImageId: "",
                profileImage: nil
            )
        )
        userRank[.commercial]?.append(
            .init(
                xpPoint: 10,
                xpTotalPoint: 100,
                title: .mockLegend,
                customerId: "112333",
                nickname: "유저11224",
                profileImageId: "",
                profileImage: nil
            )
        )
        userRank[.metro]?.append(
            .init(
                xpPoint: 10,
                xpTotalPoint: 100,
                title: .mockLegend,
                customerId: "33",
                nickname: "유저124",
                profileImageId: "",
                profileImage: nil
            )
        )
        userRank[.metro]?.append(
            .init(
                xpPoint: 120,
                xpTotalPoint: 1001,
                title: .mockLegend,
                customerId: "123",
                nickname: "유저456",
                profileImageId: "",
                profileImage: nil
            )
        )
        userRank[.metro]?.append(
            .init(
                xpPoint: 120,
                xpTotalPoint: 1001,
                title: .mockLegend,
                customerId: "1235",
                nickname: "유저2345",
                profileImageId: "",
                profileImage: nil
            )
        )
        userRank[.metro]?.append(
            .init(
                xpPoint: 120,
                xpTotalPoint: 1001,
                title: .mockLegend,
                customerId: "12323",
                nickname: "유저542",
                profileImageId: "",
                profileImage: nil
            )
        )
        userRank[.metro]?.append(
            .init(
                xpPoint: 120,
                xpTotalPoint: 1001,
                title: .mockLegend,
                customerId: "12333323",
                nickname: "유저52242",
                profileImageId: "",
                profileImage: nil
            )
        )
        userRank[.metro]?.append(
            .init(
                xpPoint: 1420,
                xpTotalPoint: 1001,
                title: .mockLegend,
                customerId: "123321233323",
                nickname: "유저52242",
                profileImageId: "",
                profileImage: nil
            )
        )
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
    let xpPoint: Int
    let xpTotalPoint: Int
    let title: Title?
    let customerId: String
    let nickname: String
    let profileImageId: String?
    let profileImage: UIImage?
    
    init(xpPoint: Int, xpTotalPoint: Int, title: Title?, customerId: String, nickname: String, profileImageId: String?, profileImage: UIImage?) {
        self.xpPoint = xpPoint
        self.xpTotalPoint = xpTotalPoint
        self.title = title
        self.customerId = customerId
        self.nickname = nickname
        self.profileImageId = profileImageId
        self.profileImage = profileImage
    }
    
    init(rank: StatRank) async {
        self.xpPoint = rank.xpPoint
        self.xpTotalPoint = rank.xpTotalPoint
        self.title = rank.title
        self.customerId = rank.customerId
        self.nickname = rank.nickname
        self.profileImageId = rank.profileImageId
        self.profileImage = await ImageCacheService.shared.loadImageAsync(imageId: rank.profileImageId ?? "")
    }
}
