//
//  Quest.swift
//  ILSANG
//
//  Created by Lee Jinhee on 5/22/24.
//

import UIKit

@Observable
class QuestViewModelItem: Hashable, Identifiable {
    static func == (lhs: QuestViewModelItem, rhs: QuestViewModelItem) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    let id: String
    var image: UIImage?
    let imageId: String?
    let mainImage: UIImage?
    let mainImageId: String?
    let missionId: String
    let missionType: MissionType
    let missionTitle: String
    let writer: String
    var rewardDic: [XpStat: Int]
    let type: String
    let target: String
    let expireDate: String
    var challengeImageIds: [ChallengeImage]
    var challengeImages: [UIImage]
    var customerRank: Int
    var favoriteYn: Bool
    
    init(
        id: String,
        image: UIImage? = nil,
        imageId: String,
        mainImage: UIImage? = nil,
        mainImageId: String,
        missionId: String,
        missionType: MissionType,
        missionTitle: String,
        writer: String,
        rewardDic: [XpStat: Int],
        type: String,
        target: String,
        expireDate: String,
        challengeImageIds: [ChallengeImage],
        challengeImages: [UIImage],
        customerRank: Int,
        favoriteYn: Bool
    ) {
        self.id = id
        self.image = image
        self.imageId = imageId
        self.mainImage = mainImage
        self.mainImageId = mainImageId
        self.missionId = missionId
        self.missionType = missionType
        self.missionTitle = missionTitle
        self.writer = writer
        self.rewardDic = rewardDic
        self.type = type
        self.target = target
        self.expireDate = expireDate
        self.challengeImageIds = challengeImageIds
        self.challengeImages = challengeImages
        self.customerRank = customerRank
        self.favoriteYn = favoriteYn
    }
    
    init(quest: Quest) {
        self.id = quest.questId
        self.image = nil
        self.imageId = quest.imageId
        self.mainImage = nil
        self.mainImageId = quest.mainImageId
        self.missionId = quest.missionId
        self.missionType = MissionType(rawValue: quest.missionType) ?? .image
        self.missionTitle = quest.missionTitle
        self.writer = quest.writer
        self.rewardDic = [:]
        self.type = quest.type
        self.target = quest.target
        self.expireDate = quest.expireDate
        self.challengeImageIds = []
        self.challengeImages = []
        self.customerRank = 0
        self.favoriteYn = quest.favoriteYn
        
        for reward in quest.rewardList where reward.quantity > 0 && reward.type == "XP" {
            if let content = reward.content, let stat = XpStat(rawValue: content.lowercased()) {
                rewardDic[stat] = reward.quantity
            }
        }
    }
    var isEventQuest: Bool { self.type == "EVENT" }
    var isRepeatQuest: Bool { self.type == "REPEAT" }
    var repeatType: RepeatType? { RepeatType(rawValue: self.target.lowercased()) ?? nil }
    
    enum QuizType: Hashable {
        case text, ox
        
        init?(rawValue: String) {
            switch rawValue {
            case "WORDS": self = .text
            case "OX": self = .ox
            default: return nil
            }
        }
        
        var description: String {
            switch self {
            case .text:
                "서술형"
            case .ox:
                "OX"
            }
        }
        
    }
    
    enum MissionType: Equatable, Hashable {
        
        case quiz(QuizType), image
        
        init?(rawValue: String) {
            if let quizType = QuizType(rawValue: rawValue) {
                self = .quiz(quizType)
            } else if rawValue == "FREE" {
                self = .image
            } else {
                return nil
            }
        }
        
        var description: String {
            switch self {
            case .quiz(let quizType):
                quizType.description
            case .image:
                "사진인증"
            }
        }
    }
    
    func totalRewardXP() -> Int {
        self.rewardDic.values.reduce(0, +)
    }
    
    func updateChallengeImages(challengeImageIds: [ChallengeImage], customerRank: Int?) async {
        self.challengeImageIds = challengeImageIds
        self.customerRank = customerRank ?? 0
        
        let newImages = await withTaskGroup(of: UIImage?.self) { group -> [UIImage] in
            var images: [UIImage] = []
            
            for challenge in challengeImageIds {
                group.addTask {
                    await ImageCacheService.shared.loadImageAsync(imageId: challenge.receiptImage)
                }
            }
            for await image in group {
                if let image = image {
                    images.append(image)
                }
            }
            
            return images
        }
        self.challengeImages = newImages
    }
}

extension QuestViewModelItem {
    static let mockImageId = "IMQU2024071520500801"
    
    static let mockData: QuestViewModelItem = QuestViewModelItemBuilder()
        .setMissionTitle("러닝 30분하기")
        .setRewardDic([.fun: 15, .strength: 5])
        .setFavoriteYn(true)
        .setChallengeImageIds([.init(challengeId: "CH001", receiptImage: "", status: "")])
        .build()
    
    static let mockRepeatData: QuestViewModelItem = QuestViewModelItemBuilder()
        .setMissionTitle("러닝 30분하기")
        .setRepeatType(.daily)
        .setRewardDic([.fun: 15, .strength: 5])
        .setFavoriteYn(true)
        .setChallengeImageIds([.init(challengeId: "CH001", receiptImage: "", status: "")])
        .setCustomerRank(2)
        .build()
    
    static let mockQuestList: [QuestViewModelItem] = [
        QuestViewModelItemBuilder()
            .setMissionTitle("미라클모닝 실천하기")
            .setRepeatType(.daily)
            .setRewardDic([.strength: 15, .intellect: 5])
            .setFavoriteYn(true)
            .setChallengeImageIds([.init(challengeId: "CH001", receiptImage: "", status: "")])
            .setCustomerRank(2)
            .build(),
        
        QuestViewModelItemBuilder()
            .setMissionTitle("가족 사랑 지킴이")
            .setRepeatType(.weekly)
            .setMissionType(.quiz(.ox))
            .setRewardDic([.sociability: 20, .charm: 10])
            .setCustomerRank(3)
            .build(),
        
        QuestViewModelItemBuilder()
            .setMissionTitle("감정 코칭 마스터")
            .setRewardDic([.intellect: 15, .charm: 5])
            .setFavoriteYn(true)
            .setMainImage(.logo)
            .setMissionType(.quiz(.text))
            .build(),
        
        QuestViewModelItemBuilder()
            .setMissionTitle("미션 타이틀")
            .setWriter("루틴디자이너")
            .setRepeatType(.weekly)
            .setRewardDic([.intellect: 20])
            .setFavoriteYn(true)
            .setCustomerRank(2)
            .build(),
        
        QuestViewModelItemBuilder()
            .setId("quest-106")
            .setMissionTitle("🎨 취미탐험가")
            .setWriter("취미부스터")
            .setRepeatType(.monthly)
            .setRewardDic([.fun: 30, .intellect: 5])
            .setFavoriteYn(true)
            .setCustomerRank(3)
            .build(),
        
        QuestViewModelItemBuilder()
            .setId("quest-107")
            .setMissionTitle("📚 가계부 전략가")
            .setWriter("절약미학자")
            .setRepeatType(.weekly)
            .setRewardDic([.intellect: 25])
            .setCustomerRank(5)
            .build(),
        
        QuestViewModelItemBuilder()
            .setMissionTitle("운동 30분하기")
            .setRepeatType(.daily)
            .setRewardDic([.fun: 15, .strength: 15])
            .setFavoriteYn(true)
            .setCustomerRank(1)
            .build(),
        
        QuestViewModelItemBuilder()
            .setMissionTitle("카페라떼 마시기")
            .setRewardDic([.fun: 20])
            .setFavoriteYn(true)
            .build()
    ]
}
