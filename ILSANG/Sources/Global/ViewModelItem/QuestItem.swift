//
//  Quest.swift
//  ILSANG
//
//  Created by Lee Jinhee on 5/22/24.
//

import UIKit

@Observable
class QuestItem: Hashable, Identifiable {
    static func == (lhs: QuestItem, rhs: QuestItem) -> Bool {
        lhs.id == rhs.id &&
        lhs.questType == rhs.questType &&
        lhs.repeatType == rhs.repeatType &&
        lhs.favoriteYn == rhs.favoriteYn &&
        lhs.rewards == rhs.rewards &&
        lhs.missions == rhs.missions &&
        lhs.mainImage == rhs.mainImage &&
        lhs.image == rhs.image &&
        lhs.userRank == rhs.userRank
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    let id: Int
    let title: String
    let writer: String
    let questType: QuestType?
    let repeatType: RepeatType?
    let rewards: [Reward]?
    var missions: [Mission]
    var coupons: [CouponItem]
    let expireDate: Date?
    let imageId: String?
    var image: UIImage?
    let mainImageId: String?
    var mainImage: UIImage?
    let userRank: Int?
    var favoriteYn: Bool
    
    init(
        id: Int,
        title: String,
        writer: String,
        questType: QuestType?,
        repeatType: RepeatType?,
        rewards: [Reward]?,
        missions: [Mission],
        coupons: [CouponItem],
        expireDate: Date?,
        imageId: String?,
        image: UIImage?,
        mainImageId: String?,
        mainImage: UIImage?,
        userRank: Int?,
        favoriteYn: Bool
    ) {
        self.id = id
        self.title = title
        self.writer = writer
        self.questType = questType
        self.repeatType = repeatType
        self.rewards = rewards
        self.missions = missions
        self.coupons = coupons
        self.expireDate = expireDate
        self.imageId = imageId
        self.image = image
        self.mainImageId = mainImageId
        self.mainImage = mainImage
        self.userRank = userRank
        self.favoriteYn = favoriteYn
    }
    
    var missionType: MissionType { missions.first?.type ?? .photo }
    var challengeImages: [UIImage] = []
    var missionId: Int { missions.first?.id ?? 0}
    var coupon: CouponItem? { coupons.first }
    var hasCouponReward: Bool { !coupons.isEmpty }
    
    func totalRewardPoint() -> Int {
        self.rewards?.reduce(0) { $0 + $1.point } ?? 0
    }
}

extension QuestItem {
    static let mockImageId = "IMQU2024071520500801"
    
    static let mockData: QuestItem = QuestItemBuilder()
        .setTitle("러닝 30분하기")
        .setReward([Reward(point: 110, pointType: .metro), Reward(point: 10, pointType: .commercial), Reward(point: 10, pointType: .contribution)])
        .setFavoriteYn(true)
        .setChallengeImageIds([""])
        .build()
    static let mockRepeatData: QuestItem = QuestItemBuilder()
        .setTitle("러닝 30분하기")
        .setRepeatType(.daily)
        .setCoupons([CouponItem.mockData])
        .setReward([Reward(point: 110, pointType: .metro), Reward(point: 10, pointType: .commercial), Reward(point: 10, pointType: .contribution)])
        .setFavoriteYn(true)
        .setChallengeImageIds([""])
        .setCustomerRank(2)
        .build()
    static let mockOXData: QuestItem = QuestItemBuilder()
        .setTitle("러닝 30분하기")
        .setNormalType()
        .setCoupons([CouponItem.mockData])
        .setMission(.init(id: 0, type: .quiz(.ox), exampleImageIds: []))
        .setReward([Reward(point: 110, pointType: .metro), Reward(point: 10, pointType: .commercial), Reward(point: 10, pointType: .contribution)])
        .setFavoriteYn(true)
        .build()
    
    static let mockQuestList: [QuestItem] = [mockData, mockRepeatData]
}
