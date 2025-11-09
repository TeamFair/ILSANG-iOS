//
//  UserMissionHistoryItem.swift
//  ILLSANG
//
//  Created by Lee Jinhee on 8/28/25.
//

import UIKit

@Observable
class UserMissionHistoryItem: Identifiable {
    let missionHistoryId: Int
    let title, createdAt: String
    let submitImageId: String?
    var submitImage: UIImage?
    let questImageId: String?
    var questImage: UIImage?
    let viewCount: Int
    let likeCount: Int
    let questType: QuestType?
    let repeatType: RepeatType?
    let missionType: MissionType
    
    init(
        missionHistoryId: Int,
        title: String,
        createdAt: String,
        submitImageId: String?,
        submitImage: UIImage?,
        questImageId: String?,
        questImage: UIImage?,
        viewCount: Int,
        likeCount: Int,
        questType: QuestType?,
        repeatType: RepeatType?,
        missionType: MissionType
    ) {
        self.missionHistoryId = missionHistoryId
        self.title = title
        self.createdAt = createdAt
        self.submitImageId = submitImageId
        self.submitImage = submitImage
        self.questImageId = questImageId
        self.questImage = questImage
        self.viewCount = viewCount
        self.likeCount = likeCount
        self.questType = questType
        self.repeatType = repeatType
        self.missionType = missionType
    }
}
