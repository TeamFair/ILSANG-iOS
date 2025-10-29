//
//  UserMissionHistoryDetail.swift
//  ILLSANG
//
//  Created by Lee Jinhee on 10/25/25.
//


struct UserMissionHistoryDetail {
    let missionHistoryId: Int
    let title: String
    let submitImageId, questImageId: String?
    let likeCount: Int
    let createdAt, commercialAreaCode: String
    let questType: QuestType
    let missionType: MissionType
    let repeatType: RepeatType?
    let writerName: String
    let commercialGainPoint, metroGainPoint, contributionGainPoint: Int
    let quizList: [MissionHistoryQuiz]?
}

extension UserMissionHistoryDetail {
    static let mockData = UserMissionHistoryDetail(
        missionHistoryId: 1,
        title: "타이틀",
        submitImageId: "",
        questImageId: "",
        likeCount: 0,
        createdAt: "",
        commercialAreaCode: "",
        questType: .event,
        missionType: .photo,
        repeatType: nil,
        writerName: "",
        commercialGainPoint: 10,
        metroGainPoint: 10,
        contributionGainPoint: 10,
        quizList: []
    )
}

struct MissionHistoryQuiz {
    let id: Int
    let question: String
    let answers: [String]
    let userAnswer: String
}
