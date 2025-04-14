//
//  Quest.swift
//  ILSANG
//
//  Created by Lee Jinhee on 7/18/24.
//

struct Quest: Codable {
    let questId: String
    let writer: String
    let missionId: String
    let missionTitle: String
    let missionType: String
    let status: String
    let expireDate: String
    let creatorRole: String
    let imageId, mainImageId: String?
    let popularYn: Bool
    let rewardList: [Reward]
    let type: String
    let target: String
    let score: Int
    let favoriteYn: Bool
}

struct QuestDetail: Codable {
    let questId: String
    let missionTitles: [String]
    let rewardList: [Reward]
    let status, expiredData, imageId: String
    let score: Int
    let type, target: String
    let topLikeChallenges: [ChallengeImage]
    let customerRank: Int?
    let favoriteYn: Bool
}

struct ChallengeImage: Codable, Hashable {
    let challengeId: String
    let receiptImage: String
    let status: String
}

struct Reward: Codable {
    let quantity: Int
    let content: String?
    let type: String
}
