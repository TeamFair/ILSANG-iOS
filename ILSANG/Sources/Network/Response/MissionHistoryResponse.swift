//
//  MissionHistoryResponse.swift
//  ILLSANG
//
//  Created by Lee Jinhee on 8/18/25.
//

import Foundation

struct MissionHistoryResponse: Decodable {
    let missionHistoryId: Int
    let user: User
    let title, createdAt: String
    let likeCount, hateCount, viewCount: Int
    let imageId, commercialAreaCode: String
    let emojis: [EmojiType]
    
    struct User: Decodable {
        let userId, nickname: String
        let profileImageId: String?
        let title: UserTitleResponse?
    }
    
    enum CodingKeys: String, CodingKey {
        case missionHistoryId
        case user
        case title
        case createdAt
        case likeCount
        case hateCount
        case viewCount
        case imageId = "submitImageId"
        case commercialAreaCode
        case emojis = "currentUserEmojis"
    }
}
