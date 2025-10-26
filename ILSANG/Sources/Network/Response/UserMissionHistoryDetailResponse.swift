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
    let quizList: [MissionHistoryQuizResponse]?

    private enum CodingKeys: String, CodingKey {
        case missionHistoryId, title, submitImageId, questImageId, likeCount,
             createdAt, commercialAreaCode, questType, missionType, writerName, repeatFrequency,
             commercialGainPoint, metroGainPoint, contributionGainPoint, quizList
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        missionHistoryId = try container.decode(Int.self, forKey: .missionHistoryId)
        title = try container.decode(String.self, forKey: .title)
        submitImageId = try container.decodeIfPresent(String.self, forKey: .submitImageId)
        questImageId = try container.decodeIfPresent(String.self, forKey: .questImageId)
        likeCount = try container.decode(Int.self, forKey: .likeCount)
        createdAt = try container.decode(String.self, forKey: .createdAt)
        commercialAreaCode = try container.decode(String.self, forKey: .commercialAreaCode)
        questType = try container.decode(String.self, forKey: .questType)
        missionType = try container.decode(String.self, forKey: .missionType)
        writerName = try container.decode(String.self, forKey: .writerName)
        repeatFrequency = try container.decodeIfPresent(String.self, forKey: .repeatFrequency)
        commercialGainPoint = try container.decode(Int.self, forKey: .commercialGainPoint)
        metroGainPoint = try container.decode(Int.self, forKey: .metroGainPoint)
        contributionGainPoint = try container.decode(Int.self, forKey: .contributionGainPoint)
        quizList = try? container.decodeIfPresent([MissionHistoryQuizResponse].self, forKey: .quizList) ?? [] // null 대응
    }
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
