//
//  BannerQuestResponse+Mapping.swift
//  ILLSANG
//
//  Created by Lee Jinhee on 9/7/25.
//

import Foundation

extension BannerQuestResponse: DomainConvertible {
    func toDomain() -> Quest {
        let formatter = ISO8601DateFormatter()
        let date = formatter.date(from: expireDate) ?? Date()
        
        return Quest(
            id: questId,
            title: title,
            writer: writerName,
            questType: QuestType(rawValue: questType),
            repeatFrequency: repeatFrequency.flatMap { RepeatType(param: $0) },
            rewards: rewards.map { $0.toDomain() },
            missions: [],
            expireDate: date,
            imageId: imageId,
            mainImageId: mainImageId,
            userRank: nil,
            favoriteYn: nil
        )
    }
}
