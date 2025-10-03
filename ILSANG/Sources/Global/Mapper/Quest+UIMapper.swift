//
//  Quest+UIMapper.swift
//  ILLSANG
//
//  Created by Lee Jinhee on 8/22/25.
//

extension Quest {
    func toQuestItem() -> QuestViewModelItem {
        return QuestViewModelItem(
            id: id,
            title: title,
            writer: writer,
            questType: questType,
            repeatType: repeatFrequency,
            rewards: rewards,
            missions: missions,
            coupons: coupons.map { $0.toCoupon() },
            expireDate: expireDate,
            imageId: imageId,
            image: nil,
            mainImageId: mainImageId,
            mainImage: nil,
            userRank: userRank,
            favoriteYn: favoriteYn ?? false
        )
    }
}
