//
//  BaseQuestResponse+Mapping.swift
//  ILSANG
//
//  Created by Lee Jinhee on 8/23/25.
//

import Foundation

extension BaseQuestResponse: DomainConvertible {
    func toDomain() -> Quest {
        Quest(
            id: questId,
            title: title,
            writer: writerName,
            questType: self.questType.flatMap { QuestType(rawValue: $0) },
            repeatFrequency: self.repeatFrequency.flatMap { RepeatType(param: $0) },
            rewards: rewards.compactMap { $0.toDomain() },
            missions: [],
            coupons: [],
            expireDate: expireDate.toISO8601Date(),
            imageId: imageId,
            mainImageId: mainImageId,
            userRank: nil,
            favoriteYn: favoriteYn,
            lastCompleteDate: lastCompleteDate?.toISO8601Date(),
            commercialAreaCode: commercialAreaCode,
        )
    }
}
