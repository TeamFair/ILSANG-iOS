//
//  UserMissionHistory.swift
//  ILLSANG
//
//  Created by Lee Jinhee on 8/28/25.
//

struct UserMissionHistory {
    let missionHistoryId: Int
    let title, createdAt: String
    let submitImageId: String?
    let questImageId: String?
    let viewCount: Int
    let likeCount: Int
    let questType: QuestType
    let repeatType: RepeatType?
    let missionType: MissionType
}
