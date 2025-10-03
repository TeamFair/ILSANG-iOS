//
//  LargeRewardQuestResponse+Mapping.swift
//  ILSANG
//
//  Created by Lee Jinhee on 8/23/25.
//

import Foundation

extension LargeRewardQuestResponse: DomainConvertible {
    func toDomain() -> Quest {
        let formatter = ISO8601DateFormatter()
        let date = formatter.date(from: expireDate) ?? Date()
        
        return Quest(
            id: questId,
            title: title,
            writer: writerName,
            questType: nil,
            repeatFrequency: nil,
            rewards: rewards.map { $0.toDomain() },
            missions: [],
            coupons: [],
            expireDate: date,
            imageId: imageId,
            mainImageId: mainImageId,
            userRank: nil,
            favoriteYn: nil
        )
    }
}
