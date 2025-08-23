//
//  BaseQuestResponse+Mapping.swift
//  ILSANG
//
//  Created by Lee Jinhee on 8/23/25.
//

import Foundation

extension BaseQuestResponse: DomainConvertible {
    func toDomain() -> Quest {
        let formatter = ISO8601DateFormatter()
        let date = formatter.date(from: expireDate) ?? Date()
        
        return Quest(
            id: questId,
            title: title,
            writer: writerName,
            questType: self.questType.flatMap { QuestType(rawValue: $0) },
            repeatFrequency: self.repeatFrequency.flatMap { RepeatType(rawValue: $0) },
            rewards: rewards.map { $0.toDomain() },
            missions: nil,
            expireDate: date,
            imageId: imageId,
            mainImageId: mainImageId,
            userRank: nil,
            favoriteYn: favoriteYn
        )
    }
}
