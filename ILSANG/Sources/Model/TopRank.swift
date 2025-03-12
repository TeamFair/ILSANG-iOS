//
//  TopRank.swift
//  ILSANG
//
//  Created by Lee Jinhee on 1/17/25.
//

import Foundation

struct TopRank: Decodable {
    let customerId: String
    let lank: Int
    let xpSum: Int
    let nickname: String
    let profileImageId: String?
    
    enum CodingKeys: String, CodingKey {
        case customerId
        case lank
        case xpSum
        case nickname
        case profileImageId = "profileImage"
    }
}
