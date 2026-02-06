//
//  LargeRewardQuestResponse+Mapping.swift
//  ILSANG
//
//  Created by Lee Jinhee on 8/23/25.
//

import Foundation

extension LargeRewardQuestResponse: DomainConvertible {
    func toDomain() -> Quest {
        Quest(
            id: questId,
            title: title,
            writer: writerName,
            questType: nil,
            repeatFrequency: nil,
            rewards: rewards.compactMap { $0.toDomain() },
            missions: [],
            coupons: [],
            expireDate: expireDate.toISO8601Date(),
            imageId: imageId,
            mainImageId: mainImageId,
            userRank: nil,
            favoriteYn: nil,
            lastCompleteDate: nil,
            commercialAreaCode: nil
        )
    }
}
