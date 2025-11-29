//
//  UserMissionHistory+Mapping.swift
//  ILLSANG
//
//  Created by Lee Jinhee on 8/28/25.
//


extension UserMissionHistoryResponse {
    func toDomain() -> UserMissionHistory {
        guard let missionType = MissionType(rawValue: missionType) else {
            fatalError("MissionType 초기화 실패")
        }
        
        return UserMissionHistory(
            missionHistoryId: missionHistoryId,
            title: title,
            createdAt: createdAt,
            submitImageId: submitImageId,
            questImageId: questImageId,
            viewCount: viewCount,
            likeCount: likeCount,
            questType: QuestType(rawValue: questType),
            repeatType: repeatFrequency.flatMap { RepeatType(param: $0) },
            missionType: missionType
        )
    }
}
