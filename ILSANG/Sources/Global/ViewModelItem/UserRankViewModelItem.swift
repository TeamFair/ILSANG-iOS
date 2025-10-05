//
//  UserRankViewModelItem.swift
//  ILSANG
//
//  Created by Lee Jinhee on 8/25/25.
//

import UIKit

class UserRankViewModelItem: ObservableObject {
    let userId: String
    let profileImageId: String?
    @Published var profileImage: UIImage?
    let nickname: String
    let point: Int
    let rank: Int
    let title: UserTitleResponse?
    let pointGap: Int?
    
    init(userId: String, profileImageId: String?, profileImage: UIImage?, nickname: String, point: Int, rank: Int, title: UserTitleResponse?, pointGap: Int?) {
        self.userId = userId
        self.profileImageId = profileImageId
        self.profileImage = profileImage
        self.nickname = nickname
        self.point = point
        self.rank = rank
        self.title = title
        self.pointGap = pointGap
    }
}

extension UserRankViewModelItem {
    static let mockData1 = UserRankViewModelItem(userId: "", profileImageId: "", profileImage: .img0, nickname: "일상", point: 100000, rank: 1, title: .init(titleHistoryId: 0, name: "칭호", grade: "LEGEND", type: "METRO", createdAt: ""), pointGap: nil)
    static let mockData100 =  UserRankViewModelItem(userId: "", profileImageId: "", profileImage: nil, nickname: "김일상", point: 100, rank: 100, title: .init(titleHistoryId: 5, name: "칭호", grade: "LEGEND", type: "METRO", createdAt: ""), pointGap: 10)
    static let mockData1000 =  UserRankViewModelItem(userId: "", profileImageId: "", profileImage: .img0, nickname: "김일상", point: 1000, rank: 1000, title: .init(titleHistoryId: 3, name: "칭호", grade: "STANDARD", type: "METRO", createdAt: ""), pointGap: nil)
}
