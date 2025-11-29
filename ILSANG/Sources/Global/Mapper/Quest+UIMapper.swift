//
//  Quest+UIMapper.swift
//  ILLSANG
//
//  Created by Lee Jinhee on 8/22/25.
//

extension Quest {
    func toQuestItem(myCommercialCode: String?, questCommercialCode: String?) -> QuestItem {
        // commercialAreaCode 우선, 없으면 questCommercialCode로 비교
        let compareCode = commercialAreaCode ?? questCommercialCode
        let isMyIllsangZone: Bool

        if let compareCode, let myCommercialCode {
            isMyIllsangZone = compareCode == myCommercialCode
        } else {
            isMyIllsangZone = false
        }
        
        return QuestItem(
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
            favoriteYn: favoriteYn ?? false,
            lastCompleteDate: lastCompleteDate,
            commercialAreaCode: commercialAreaCode,
            isMyIllsangZone: isMyIllsangZone
        )
    }
    
    func toQuestItem(isMyIllsangZone: Bool) -> QuestItem {
        return QuestItem(
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
            favoriteYn: favoriteYn ?? false,
            lastCompleteDate: lastCompleteDate,
            commercialAreaCode: commercialAreaCode,
            isMyIllsangZone: isMyIllsangZone
        )
    }
}
