//
//  QuestViewModelItemBuilder.swift
//  ILSANG
//
//  Created by Lee Jinhee on 5/19/25.
//

import UIKit

final class QuestViewModelItemBuilder {
    private var id: String = UUID().uuidString
    private var image: UIImage? = nil
    private var imageId: String = QuestViewModelItem.mockImageId
    private var mainImage: UIImage? = nil
    private var mainImageId: String = "default_main_image_id"
    private var missionId: String = UUID().uuidString
    private var missionType: QuestViewModelItem.MissionType = .image
    private var missionTitle: String = "기본 미션 제목"
    private var writer: String = "일상"
    private var rewardDic: [XpStat: Int] = [:]
    private var type: String = "NORMAL" // REPEAT
    private var target: String = "NONE" // DAILY, WEEKLY, MONTHLY
    private var expireDate: String = "2030-12-30T00:00:00"
    private var challengeImageIds: [ChallengeImage] = []
    private var challengeImages: [UIImage] = []
    private var customerRank: Int = 0
    private var favoriteYn: Bool = false
    
    enum MissionTarget: String {
        case none = "NONE", daily = "DAILY", weekly = "WEEKLY", monthly = "MONTHLY"
    }
    
    func setId(_ id: String) -> Self {
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
    
    func setMissionId(_ missionId: String) -> Self {
        self.missionId = missionId
        return self
    }
    
    func setMissionType(_ missionType: QuestViewModelItem.MissionType) -> Self {
        self.missionType = missionType
        return self
    }
    
    func setMissionTitle(_ missionTitle: String) -> Self {
        self.missionTitle = missionTitle
        return self
    }
    
    func setWriter(_ writer: String) -> Self {
        self.writer = writer
        return self
    }
    
    func setRewardDic(_ rewardDic: [XpStat: Int]) -> Self {
        self.rewardDic = rewardDic
        return self
    }
    
    func setNormalType() -> Self {
        self.type = "NORMAL"
        self.target = "NONE"
        return self
    }
    
    func setRepeatType(_ target: MissionTarget) -> Self {
        self.type = "REPEAT"
        self.target = target.rawValue
        return self
    }
    
    func setExpireDate(_ expireDate: String) -> Self {
        self.expireDate = expireDate
        return self
    }
    
    func setChallengeImageIds(_ challengeImageIds: [ChallengeImage]) -> Self {
        self.challengeImageIds = challengeImageIds
        return self
    }
    
    func setChallengeImages(_ challengeImages: [UIImage]) -> Self {
        self.challengeImages = challengeImages
        return self
    }
    
    func setCustomerRank(_ customerRank: Int) -> Self {
        if self.type != "REPEAT" {
            Log("Warning: customerRank는 REPEAT 퀘스트에만 적용됩니다.")
            return self
        }
        self.customerRank = customerRank
        return self
    }
    
    func setFavoriteYn(_ favoriteYn: Bool) -> Self {
        self.favoriteYn = favoriteYn
        return self
    }
        
    func build() -> QuestViewModelItem {
        return QuestViewModelItem(
            id: id,
            image: image,
            imageId: imageId,
            mainImage: mainImage,
            mainImageId: mainImageId,
            missionId: missionId,
            missionType: missionType,
            missionTitle: missionTitle,
            writer: writer,
            rewardDic: rewardDic,
            type: type,
            target: target,
            expireDate: expireDate,
            challengeImageIds: challengeImageIds,
            challengeImages: challengeImages,
            customerRank: customerRank,
            favoriteYn: favoriteYn
        )
    }
}
