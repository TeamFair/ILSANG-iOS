//
//  MissionHistoryResponse+Mapping.swift
//  ILLSANG
//
//  Created by Lee Jinhee on 8/18/25.
//

import Foundation

extension MissionHistoryResponse {
    func toDomain() -> MissionHistory {
        let formatter = ISO8601DateFormatter()
        let date = formatter.date(from: createdAt) ?? Date()
        
        let userTitle = user.title.flatMap { title in
            HonorGrade(rawValue: title.grade).flatMap { gradeEnum in
                UserTitle(name: title.name, grade: gradeEnum)
            }
        }
        
        return MissionHistory(
            id: missionHistoryId,
            title: title,
            createdAt: date,
            likeCount: likeCount,
            hateCount: hateCount,
            viewCount: viewCount,
            imageId: imageId,
            commercialAreaName: commercialAreaCode, // TODO: 지역시스템: 코드 -> 지역명으로 변경
            userId: user.userId,
            nickname: user.nickname,
            profileImageId: user.profileImageId,
            userTitle: userTitle
        )
    }
}
