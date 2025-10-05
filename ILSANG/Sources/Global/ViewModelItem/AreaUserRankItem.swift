//
//  AreaUserRankItem.swift
//  ILSANG
//
//  Created by Lee Jinhee on 8/25/25.
//

import Combine

class AreaUserRankItem: ObservableObject {
    let ranks: [UserRankItem]
    let user: UserRankItem?
    
    init(ranks: [UserRankItem], user: UserRankItem?) {
        self.ranks = ranks
        self.user = user
    }
}

extension AreaUserRankItem {
    static let mockData1 = AreaUserRankItem(ranks: [UserRankItem.mockData1], user: UserRankItem.mockData100)
//    static let mockData1 = AreaRankViewModelItem(areaCode: "", areaName: "서현", point: 10000, imageIds: [], rank: 1)
//    static let mockData100 = AreaRankViewModelItem(areaCode: "", areaName: "서현", point: 10000, imageIds: [], rank: 100)
//    static let mockData1000 = AreaRankViewModelItem(areaCode: "", areaName: "서현", point: 100, imageIds: [], rank: 1000)
}
