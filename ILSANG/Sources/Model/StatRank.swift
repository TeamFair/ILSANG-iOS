//
//  Rank.swift
//  ILSANG
//
//  Created by Lee Jinhee on 12/11/24.
//

struct StatRank: Decodable {
    let xpType: String
    let xpPoint: Int
    let customerId: String
    let nickname: String
    let profileImageId: String?
    
    enum CodingKeys: String, CodingKey {
        case xpType
        case xpPoint
        case customerId
        case nickname
        case profileImageId = "profileImage"
    }
}

extension StatRank {
    static let mockDataList: [StatRank] = [
        StatRank(xpType: "CHARM", xpPoint: 200, customerId: "1234-5678-91011", nickname: "TestUser1", profileImageId: nil),
        StatRank(xpType: "STRENGTH", xpPoint: 150, customerId: "2234-5678-91011", nickname: "TestUser2", profileImageId: nil),
        StatRank(xpType: "CHARM", xpPoint: 300, customerId: "3234-5678-91011", nickname: "TestUser3", profileImageId: nil)
    ]
}
