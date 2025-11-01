//
//  UserMissionHistoryDetailItem.swift
//  ILLSANG
//
//  Created by Lee Jinhee on 10/25/25.
//

import UIKit

@Observable
class UserMissionHistoryDetailItem {
    let missionHistoryId: Int
    let title, createdAt: String
    let submitImageId: String?
    var submitImage: UIImage?
    let likeCount: Int
    let writerName: String
    let questType: QuestType?
    let repeatType: RepeatType?
    let missionType: MissionType
    let commercialGainPoint, metroGainPoint, contributionGainPoint: Int
    let quizList: [MissionHistoryQuiz]?
    let contributionDoublePointYn: Bool
    
    init(
        missionHistoryId: Int,
        title: String,
        createdAt: String,
        submitImageId: String?,
        submitImage: UIImage? = nil,
        likeCount: Int,
        writerName: String,
        questType: QuestType?,
        repeatType: RepeatType?,
        missionType: MissionType,
        commercialGainPoint: Int,
        metroGainPoint: Int,
        contributionGainPoint: Int,
        contributionDoublePointYn: Bool,
        quizList: [MissionHistoryQuiz]?
    ) {
        self.missionHistoryId = missionHistoryId
        self.title = title
        self.createdAt = createdAt
        self.submitImageId = submitImageId
        self.submitImage = submitImage
        self.likeCount = likeCount
        self.writerName = writerName
        self.questType = questType
        self.repeatType = repeatType
        self.missionType = missionType
        self.commercialGainPoint = commercialGainPoint
        self.metroGainPoint = metroGainPoint
        self.contributionGainPoint = contributionGainPoint
        self.contributionDoublePointYn = contributionDoublePointYn
        self.quizList = quizList
    }
}
