//
//  AreaUserRankViewModelItem.swift
//  ILSANG
//
//  Created by Lee Jinhee on 8/25/25.
//

import Combine

class AreaUserRankViewModelItem: ObservableObject {
    let ranks: [UserRankViewModelItem]
    let user: UserRankViewModelItem?
    
    init(ranks: [UserRankViewModelItem], user: UserRankViewModelItem?) {
        self.ranks = ranks
        self.user = user
    }
}

extension AreaUserRankViewModelItem {
    static let mockData1 = AreaUserRankViewModelItem(ranks: [UserRankViewModelItem.mockData1], user: UserRankViewModelItem.mockData100)
//    static let mockData1 = AreaRankViewModelItem(areaCode: "", areaName: "서현", point: 10000, imageIds: [], rank: 1)
//    static let mockData100 = AreaRankViewModelItem(areaCode: "", areaName: "서현", point: 10000, imageIds: [], rank: 100)
//    static let mockData1000 = AreaRankViewModelItem(areaCode: "", areaName: "서현", point: 100, imageIds: [], rank: 1000)
}
