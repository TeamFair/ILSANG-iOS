//
//  QuestDetailResponse.swift
//  ILSANG
//
//  Created by Lee Jinhee on 8/21/25.
//


struct QuestDetailResponse: Decodable {
    let id: Int
    let writerName: String
    let questType: String
    let repeatFrequency: String?
    let title: String
    let mainImageId: String?
    let imageId: String
    let userRank: Int?
    let expireDate: String // "2025-08-21T11:53:17.556Z",
    let favoriteYn: Bool
    let rewards: [RewardResponse]
    let missions: [MissionResponse]
}
