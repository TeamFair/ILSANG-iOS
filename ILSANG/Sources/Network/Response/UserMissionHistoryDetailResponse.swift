//
//  UserMissionHistoryDetailResponse.swift
//  ILSANG
//
//  Created by Lee Jinhee on 10/25/25.
//

struct UserMissionHistoryDetailResponse: Decodable {
    let missionHistoryId: Int
    let title: String
    let submitImageId, questImageId: String?
    let likeCount: Int
    let createdAt, commercialAreaCode, questType, missionType, writerName: String
    let repeatFrequency: String?
    let commercialGainPoint, metroGainPoint, contributionGainPoint: Int
    let contributionDoublePointYn: Bool
    let quizList: [MissionHistoryQuizResponse]?
}

struct MissionHistoryQuizResponse: Decodable {
    let id: Int
    let question: String
    let answers: [MissionHistoryQuizAnswerResponse]
    let userAnswer: String
}

struct MissionHistoryQuizAnswerResponse: Decodable {
    let id: Int
    let answer: String
    let quizId: Int
}
