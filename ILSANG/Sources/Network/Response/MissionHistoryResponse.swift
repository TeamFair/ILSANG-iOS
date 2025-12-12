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
    let likeCount, viewCount, commentCount: Int
    let imageId, commercialAreaCode: String
    let emojis: [EmojiType]
    
    let questType: String?
    let repeatFrequency: String?
    let writerName: String?
    let expireDate: String?
    var lastCompleteDate: String?
    
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
        case viewCount
        case commentCount
        case imageId = "submitImageId"
        case commercialAreaCode
        case emojis = "currentUserEmojis"
        case questType, repeatFrequency, writerName, expireDate, lastCompleteDate
    }
}
extension MissionHistoryResponse {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        missionHistoryId = try container.decode(Int.self, forKey: .missionHistoryId)
        user = try container.decode(User.self, forKey: .user)
        title = try container.decode(String.self, forKey: .title)
        createdAt = try container.decode(String.self, forKey: .createdAt)
        likeCount = try container.decode(Int.self, forKey: .likeCount)
        viewCount = try container.decode(Int.self, forKey: .viewCount)
        commentCount = try container.decode(Int.self, forKey: .commentCount)
        imageId = try container.decode(String.self, forKey: .imageId)
        commercialAreaCode = try container.decode(String.self, forKey: .commercialAreaCode)
        
        // unknown emoji 무시
        let rawEmojiValues = try container.decodeIfPresent([String].self, forKey: .emojis) ?? []
        emojis = rawEmojiValues.compactMap { EmojiType(rawValue: $0.uppercased()) }
        
        questType = try container.decodeIfPresent(String.self, forKey: .questType)
        repeatFrequency = try container.decodeIfPresent(String.self, forKey: .repeatFrequency)
        writerName = try container.decodeIfPresent(String.self, forKey: .writerName)
        expireDate = try container.decodeIfPresent(String.self, forKey: .expireDate)
        lastCompleteDate = try container.decodeIfPresent(String.self, forKey: .lastCompleteDate)
    }
}
