//
//  MissionHistory.swift
//  ILLSANG
//
//  Created by Lee Jinhee on 8/18/25.
//

import Foundation

struct MissionHistory {
    let id: Int
    let title: String
    let createdAt: Date
    let likeCount: Int
    let viewCount: Int
    let imageId: String
    let commercialAreaCode: String
    let userId: String
    let nickname: String
    let profileImageId: String?
    let userTitle: UserTitle?
    let emojis: [EmojiType]
    let questType: QuestType?
    let repeatType: RepeatType?
    let writer: String?
    let expireAt: Date?
    let lastCompleteDate: Date?
}
