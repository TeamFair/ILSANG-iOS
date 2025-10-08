//
//  QuestItemBuilder.swift
//  ILSANG
//
//  Created by Lee Jinhee on 5/19/25.
//

import UIKit

final class QuestItemBuilder {
    private var id: Int = 0
    private var image: UIImage? = nil
    private var imageId: String = QuestItem.mockImageId
    private var mainImage: UIImage? = nil
    private var mainImageId: String = "default_main_image_id"
    private var missions: [Mission] = [Mission(id: 0, type: .photo, exampleImageIds: [])]
    private var title: String = "기본 미션 제목"
    private var writer: String = "일상"
    private var rewards: [Reward] = []
    private var coupons: [CouponItem] = []
    private var questType: QuestType = .normal
    private var repeatType: RepeatType? = .daily
    private var expireDate: Date = .now
    // private var challengeImages: [UIImage] = []
    private var userRank: Int = 0
    private var favoriteYn: Bool = false
    
    func setId(_ id: Int) -> Self {
        self.id = id
        return self
    }
    
    func setImage(_ image: UIImage?) -> Self {
        self.image = image
        return self
    }
    
    func setImageId(_ imageId: String) -> Self {
        self.imageId = imageId
        return self
    }
    
    func setMainImageId(_ mainImageId: String) -> Self {
        self.mainImageId = mainImageId
        return self
    }
    
    func setMainImage(_ image: UIImage?) -> Self {
        self.mainImage = mainImage
        return self
    }
    
    func setMission(_ mission: Mission) -> Self {
        self.missions = [mission]
        return self
    }
    
    func setTitle(_ title: String) -> Self {
        self.title = title
        return self
    }
    
    func setWriter(_ writer: String) -> Self {
        self.writer = writer
        return self
    }
    
    func setReward(_ rewards: [Reward]) -> Self {
        self.rewards = rewards
        return self
    }
    
    func setCoupons(_ coupons: [CouponItem]) -> Self {
        self.coupons = coupons
        return self
    }
    
    func setNormalType() -> Self {
        self.questType = .normal
        self.repeatType = nil
        return self
    }
    
    func setRepeatType(_ repeatType: RepeatType) -> Self {
        self.questType = .repeat
        self.repeatType = repeatType
        return self
    }
    
    func setExpireDate(_ expireDate: Date) -> Self {
        self.expireDate = expireDate
        return self
    }
    
    func setChallengeImageIds(_ challengeImageIds: [String]) -> Self {
        if let firstMission = self.missions.first {
            let updatedMission = Mission(
                id: firstMission.id,
                type: firstMission.type,
                exampleImageIds: challengeImageIds
            )
            self.missions = [updatedMission]
        } else {
            let newMission = Mission(id: 1, type: .photo, exampleImageIds: challengeImageIds)
            self.missions = [newMission]
        }
        return self
    }
    
    func setCustomerRank(_ customerRank: Int) -> Self {
        if self.questType != .repeat {
            Log("Warning: customerRank는 REPEAT 퀘스트에만 적용됩니다.")
            return self
        }
        self.userRank = userRank
        return self
    }
    
    func setFavoriteYn(_ favoriteYn: Bool) -> Self {
        self.favoriteYn = favoriteYn
        return self
    }
        
    func build() -> QuestItem {
        return QuestItem(
            id: id,
            title: title,
            writer: writer,
            questType: questType,
            repeatType: repeatType,
            rewards: rewards,
            missions: missions,
            coupons: coupons,
            expireDate: expireDate,
            imageId: imageId,
            image: image,
            mainImageId: mainImageId,
            mainImage: mainImage,
            userRank: userRank,
            favoriteYn: favoriteYn
        )
    }
}
