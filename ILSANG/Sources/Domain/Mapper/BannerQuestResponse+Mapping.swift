//
//  BannerQuestResponse+Mapping.swift
//  ILLSANG
//
//  Created by Lee Jinhee on 9/7/25.
//

import Foundation

extension BannerQuestResponse: DomainConvertible {
    func toDomain() -> Quest {
        Quest(
            id: questId,
            title: title,
            writer: writerName,
            questType: QuestType(rawValue: questType),
            repeatFrequency: repeatFrequency.flatMap { RepeatType(param: $0) },
            rewards: rewards.compactMap { $0.toDomain() },
            missions: [],
            coupons: [],
            expireDate: expireDate.toISO8601Date(),
            imageId: imageId,
            mainImageId: mainImageId,
            userRank: nil,
            favoriteYn: nil,
            lastCompleteDate: lastCompleteDate?.toISO8601Date(),
            commercialAreaCode: commercialAreaCode
        )
    }
}
