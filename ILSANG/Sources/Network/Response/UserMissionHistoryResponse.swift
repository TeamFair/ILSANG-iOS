//
//  UserMissionHistory.swift
//  ILLSANG
//
//  Created by Lee Jinhee on 8/28/25.
//

import Foundation

struct UserMissionHistoryResponse: Decodable {
    let missionHistoryId: Int
    let title, createdAt: String
    let submitImageId: String?
    let questImageId: String?
    let viewCount: Int
    let likeCount: Int
    let questType: String
    let repeatFrequency: String?
    let missionType: String
    let commercialAreaCode: String
}
