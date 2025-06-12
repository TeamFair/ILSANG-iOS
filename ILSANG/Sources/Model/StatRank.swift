//
//  Rank.swift
//  ILSANG
//
//  Created by Lee Jinhee on 12/11/24.
//

struct StatRank: Decodable {
    let xpType: String
    let xpPoint: Int
    let xpTotalPoint: Int
    let title: Title?
    let customerId: String
    let nickname: String
    let profileImageId: String?
    
    enum CodingKeys: String, CodingKey {
        case xpType
        case xpPoint
        case xpTotalPoint
        case title
        case customerId
        case nickname
        case profileImageId = "profileImage"
    }
}

extension StatRank {
    static let mockDataList: [StatRank] = [
        StatRank(xpType: "CHARM", xpPoint: 200, xpTotalPoint: 200, title: nil, customerId: "1234-5678-91011", nickname: "TestUser1", profileImageId: nil),
        StatRank(xpType: "STRENGTH", xpPoint: 150, xpTotalPoint: 200, title: nil, customerId: "2234-5678-91011", nickname: "TestUser2", profileImageId: nil),
        StatRank(xpType: "CHARM", xpPoint: 300, xpTotalPoint: 200, title: nil,  customerId: "3234-5678-91011", nickname: "TestUser3", profileImageId: nil)
    ]
}
