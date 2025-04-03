//
//  Quest.swift
//  ILSANG
//
//  Created by Lee Jinhee on 5/22/24.
//

import UIKit

struct QuestViewModelItem: Hashable, Identifiable {
    let id: String
    var image: UIImage?
    let imageId: String?
    let mainImageId: String?
    let missionId: String
    let missionType: MissionType
    let missionTitle: String
    let writer: String
    var rewardDic: [XpStat: Int]
    let type: String
    let target: String
    let expireDate: String
    
    init(
        id: String,
        image: UIImage? = nil,
        imageId: String,
        mainImageId: String,
        missionId: String,
        missionType: MissionType,
        missionTitle: String,
        writer: String,
        rewardDic: [XpStat: Int],
        type: String,
        target: String,
        expireDate: String
    ) {
        self.id = id
        self.image = image
        self.imageId = imageId
        self.mainImageId = mainImageId
        self.missionId = missionId
        self.missionType = missionType
        self.missionTitle = missionTitle
        self.writer = writer
        self.rewardDic = rewardDic
        self.type = type
        self.target = target
        self.expireDate = expireDate
    }
    
    init(quest: Quest) {
        self.id = quest.questId
        self.image = nil
        self.imageId = quest.imageId
        self.mainImageId = quest.mainImageId
        self.missionId = quest.missionId
        self.missionType = MissionType(rawValue: quest.missionType) ?? .image
        self.missionTitle = quest.missionTitle
        self.writer = quest.writer
        self.rewardDic = [:]
        self.type = quest.type
        self.target = quest.target
        self.expireDate = quest.expireDate

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
}

// TODO: mockdata, 팩토리 패턴 적용
extension QuestViewModelItem {
    static let mockImageId = "IMQU2024071520500801"
    
    static let mockData: QuestViewModelItem = QuestViewModelItem(
        id: "11",
        image: .img0,
        imageId: mockImageId,
        mainImageId: mockImageId,
        missionId: "1",
        missionType: .image,
        missionTitle: "아메리카노 15잔 마시기",
        writer: "이디야커피",
        rewardDic: [.charm: 30, .intellect: 100, .fun: 5],
        type: "DEFAULT",
        target: "NONE",
        expireDate: "2030-12-30T00:00:00"
    )
    
    static let mockRepeatData: QuestViewModelItem = QuestViewModelItem(
        id: "11",
        image: .img0,
        imageId: mockImageId,
        mainImageId: mockImageId,
        missionId: "1",
        missionType: .image,
        missionTitle: "아메리카노 15잔 마시기",        writer: "이디야커피",
        rewardDic: [.charm: 30, .intellect: 100, .fun: 5],
        type: "REPEAT",
        target: "DAILY",
        expireDate: "2030-12-30T00:00:00"
    )
    
    static let mockRepeat2Data: QuestViewModelItem = QuestViewModelItem(
        id: "11",
        image: .img0,
        imageId: mockImageId,
        mainImageId: mockImageId,
        missionId: "1",
        missionType: .image,
        missionTitle: "아메리카노 15잔 마시기",        writer: "이디야커피",
        rewardDic: [.charm: 30, .intellect: 100, .fun: 5],
        type: "REPEAT",
        target: "DAILY",
        expireDate: "2030-12-30T00:00:00"
    )
    
    static let mockQuestList: [QuestViewModelItem] = [
        QuestViewModelItem(
            id: "9f8aacc9-a221-491b-98c1-f9d7d35a67fb",
            image: .img0,
            imageId: mockImageId,
            mainImageId: mockImageId,
            missionId: "1",
            missionType: .image,
            missionTitle: "아메리카노 15잔 마시기",
            writer: "이디야커피",
            rewardDic: [.charm: 3, .strength: 25],
            type: "REPEAT",
            target: "MONTHLY",
            expireDate: "2030-12-30T00:00:00"
        ),
        QuestViewModelItem(
            id: "9f8aacc9-98c1-f9d7d35a67fb",
            image: .img0,
            imageId: mockImageId,
            mainImageId: mockImageId,
            missionId: "1",
            missionType: .image,
            missionTitle: "아메리카노 15잔 마시기",
            writer: "이디야커피",
            rewardDic: [.charm: 3, .fun: 25, .sociability: 20, .strength: 25],
            type: "REPEAT",
            target: "DAILY",
            expireDate: "2030-12-30T00:00:00"
        ),
        QuestViewModelItem(
            id: "9f8aacc9-a221-4-f9d7d35a67fb",
            image: .img0,
            imageId: mockImageId,
            mainImageId: mockImageId,
            missionId: "1",
            missionType: .image,
            missionTitle: "아메리카노 15잔 마시기",
            writer: "이디야커피",
            rewardDic: [.charm: 30],
            type: "REPEAT",
            target: "WEEKLY",
            expireDate: "2030-12-30T00:00:00"
        ),
        QuestViewModelItem(
            id: "13",
            image: .img0,
            imageId: mockImageId,
            mainImageId: mockImageId,
            missionId: "1",
            missionType: .image,
            missionTitle: "아메리카노 15잔 마시기",
            writer: "투썸플레이스",
            rewardDic: [.charm: 20, .sociability: 100, .strength: 25],
            type: "DEFAULT",
            target: "NONE",
            expireDate: "2030-12-30T00:00:00"
        ),
        QuestViewModelItem(
            id: "9f89d7d35a67fb",
            image: .img0,
            imageId: mockImageId,
            mainImageId: mockImageId,
            missionId: "1",
            missionType: .image,
            missionTitle: "아메리카노 15잔 마시기",
            writer: "이디야커피",
            rewardDic: [.charm: 3, .strength: 25],
            type: "REPEAT",
            target: "MONTHLY",
            expireDate: "2030-12-30T00:00:00"
        ),
        QuestViewModelItem(
            id: "9f8aac7fb",
            image: .img0,
            imageId: mockImageId,
            mainImageId: mockImageId,
            missionId: "1",
            missionType: .image,
            missionTitle: "아메리카노 15잔 마시기",
            writer: "이디야커피",
            rewardDic: [.charm: 3, .fun: 25, .sociability: 20, .strength: 25],
            type: "REPEAT",
            target: "DAILY",
            expireDate: "2030-12-30T00:00:00"
        ),
        QuestViewModelItem(
            id: "9f8aacc9-23421-4-fd35a67fb",
            image: .img0,
            imageId: mockImageId,
            mainImageId: mockImageId,
            missionId: "1",
            missionType: .image,
            missionTitle: "아메리카노 15잔 마시기",
            writer: "이디야커피",
            rewardDic: [.charm: 30],
            type: "REPEAT",
            target: "WEEKLY",
            expireDate: "2030-12-30T00:00:00"
        ),
        QuestViewModelItem(
            id: "212132",
            image: .img0,
            imageId: mockImageId,
            mainImageId: mockImageId,
            missionId: "1",
            missionType: .image,
            missionTitle: "아메리카노 15잔 마시기",
            writer: "투썸플레이스",
            rewardDic: [.charm: 20, .sociability: 100, .strength: 25],
            type: "DEFAULT",
            target: "NONE",
            expireDate: "2030-12-30T00:00:00"
        )
    ]
}
