//
//  UserMissionHistoryDetail+Mapping.swift
//  ILLSANG
//
//  Created by Lee Jinhee on 10/25/25.
//

import Foundation

extension UserMissionHistoryDetailResponse: DomainConvertible {
    func toDomain() -> UserMissionHistoryDetail {
        guard let missionType = MissionType(rawValue: missionType) else {
            fatalError("MissionType 초기화 실패")
        }
        
        return UserMissionHistoryDetail(
            missionHistoryId: missionHistoryId,
            title: title,
            submitImageId: submitImageId,
            questImageId: questImageId,
            likeCount: likeCount,
            createdAt: createdAt,
            commercialAreaCode: commercialAreaCode,
            questType: QuestType(rawValue: questType),
            missionType: missionType,
            repeatType: repeatFrequency.flatMap { RepeatType(param: $0) },
            writerName: writerName,
            commercialGainPoint: commercialGainPoint,
            metroGainPoint: metroGainPoint,
            contributionGainPoint: contributionGainPoint,
            contributionDoublePointYn: contributionDoublePointYn,
            quizList: quizList?.map { $0.toDomain() }
        )
    }
}

extension MissionHistoryQuizResponse: DomainConvertible {
    func toDomain() -> MissionHistoryQuiz {
        MissionHistoryQuiz(
            id: id,
            question: question,
            answers: answers.map { $0.answer },
            userAnswer: userAnswer
        )
    }
}
