//
//  MissionHistoryResponse+Mapping.swift
//  ILLSANG
//
//  Created by Lee Jinhee on 8/18/25.
//

import Foundation

extension MissionHistoryResponse {
    func toDomain() -> MissionHistory { 
        let userTitle = user.title.flatMap { title in
            HonorGrade(rawValue: title.grade).flatMap { gradeEnum in
                UserTitle(name: title.name, grade: gradeEnum)
            }
        }
        
        return MissionHistory(
            id: missionHistoryId,
            title: title,
            createdAt: createdAt.toISO8601Date() ?? .now,
            likeCount: likeCount,
            hateCount: hateCount,
            viewCount: viewCount,
            imageId: imageId,
            commercialAreaCode: commercialAreaCode,
            userId: user.userId,
            nickname: user.nickname,
            profileImageId: user.profileImageId,
            userTitle: userTitle,
            emojis: emojis
        )
    }
}
