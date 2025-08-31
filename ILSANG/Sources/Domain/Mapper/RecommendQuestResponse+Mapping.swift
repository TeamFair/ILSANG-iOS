//
//  RecommendQuestResponse+Mapping.swift
//  ILSANG
//
//  Created by Lee Jinhee on 8/23/25.
//



extension RecommendQuestResponse: DomainConvertible {
    func toDomain() -> Quest {
        Quest(
            id: questId,
            title: title,
            writer: writerName,
            questType: nil,
            repeatFrequency: nil,
            rewards: nil,
            missions: [],
            expireDate: nil,
            imageId: imageId,
            mainImageId: mainImageId,
            userRank: nil,
            favoriteYn: nil
        )
    }
}
