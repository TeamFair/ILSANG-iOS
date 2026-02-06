//
//  QuestDetailResponse+Mapping.swift
//  ILSANG
//
//  Created by Lee Jinhee on 8/23/25.
//

import Foundation

extension QuestDetailResponse: DomainConvertible {
    func toDomain() -> Quest {
        Quest(
            id: id,
            title: title,
            writer: writerName,
            questType: QuestType(rawValue: questType),
            repeatFrequency: self.repeatFrequency.flatMap { RepeatType(param: $0) },
            rewards: rewards.compactMap { $0.toDomain() },
            missions: missions.map { $0.toDomain() },
            coupons: coupons.map { $0.toDomain() },
            expireDate: expireDate.toISO8601Date(),
            imageId: imageId,
            mainImageId: mainImageId,
            userRank: userRank,
            favoriteYn: favoriteYn,
            lastCompleteDate: nil,
            commercialAreaCode: nil
        )
    }
}
