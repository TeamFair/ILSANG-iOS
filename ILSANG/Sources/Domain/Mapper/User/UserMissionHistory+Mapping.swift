//
//  UserMissionHistory+Mapping.swift
//  ILLSANG
//
//  Created by Lee Jinhee on 8/28/25.
//


extension UserMissionHistoryResponse {
    func toDomain() -> UserMissionHistory {
        UserMissionHistory(
            missionHistoryId: missionHistoryId,
            title: title,
            createdAt: createdAt,
            submitImageId: submitImageId,
            questImageId: questImageId,
            viewCount: viewCount,
            likeCount: likeCount
        )
    }
}
