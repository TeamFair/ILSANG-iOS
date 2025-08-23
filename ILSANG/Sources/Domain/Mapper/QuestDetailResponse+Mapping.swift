//
//  QuestDetailResponse+Mapping.swift
//  ILSANG
//
//  Created by Lee Jinhee on 8/23/25.
//

import Foundation

extension QuestDetailResponse: DomainConvertible {
    func toDomain() -> Quest {
        let formatter = ISO8601DateFormatter()
        let date = formatter.date(from: expireDate) ?? Date()
        
        return Quest(
            id: id,
            title: title,
            writer: writerName,
            questType: QuestType(rawValue: questType),
            repeatFrequency: self.repeatFrequency.flatMap { RepeatType(param: $0) },
            rewards: rewards.map { $0.toDomain() },
            missions: missions.map { $0.toDomain() },
            expireDate: date,
            imageId: imageId,
            mainImageId: mainImageId,
            userRank: userRank,
            favoriteYn: favoriteYn
        )
    }
}
