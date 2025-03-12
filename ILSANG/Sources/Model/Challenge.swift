//
//  Challenge.swift
//  ILSANG
//
//  Created by Lee Jinhee on 6/26/24.
//

import Foundation

struct Challenge: Decodable, Hashable {
    let challengeId: String
    let customerId: String?
    let userProfileImageId: String?
    let userNickName: String?
    let missionTitle: String?
    let receiptImageId, status: String
    let questImageId: String?
    let createdAt: String
    let likeCnt, hateCnt: Int
    
    enum CodingKeys: String, CodingKey {
        case challengeId
        case customerId
        case userProfileImageId = "userProfileImage"
        case userNickName
        case missionTitle
        case receiptImageId
        case status
        case questImageId = "questImage"
        case createdAt
        case likeCnt
        case hateCnt
    }
    
    static let challengeMockData = Challenge(challengeId: "", customerId: "", userProfileImageId: nil, userNickName: "일상유저123", missionTitle: "바닐라라떼 마시기", receiptImageId: "", status: "", questImageId: "", createdAt: "2024-01-01'T'00:00:00", likeCnt: 3, hateCnt: 0)
}
