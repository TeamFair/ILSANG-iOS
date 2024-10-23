//
//  Quest.swift
//  ILSANG
//
//  Created by Lee Jinhee on 5/22/24.
//

import UIKit

enum QuestStatus: String, CaseIterable {
    case uncompleted
    case completed
    
    var headerText: String {
        switch self {
        case .uncompleted:
            "퀘스트"
        case .completed:
            "완료"
        }
    }
    
    var emptyTitle: String {
        switch self {
        case .uncompleted:
            "퀘스트를 모두 완료하셨어요!"
        case .completed:
            "완료된 퀘스트가 없어요"
        }
    }
    
    var emptySubTitle: String {
        switch self {
        case .uncompleted:
            "상상할 수 없는 퀘스트를 준비 중이니\n다음 업데이트를 기대해 주세요!"
        case .completed:
            "퀘스트를 수행하러 가볼까요?"
        }
    }
}

enum XpStat: String, CaseIterable {
    case strength
    case intellect
    case fun
    case charm
    case sociability
    
    var headerText: String {
        switch self {
        case .strength:
            "체력"
        case .intellect:
            "지능"
        case .fun:
            "재미"
        case .charm:
            "매력"
        case .sociability:
            "사회성"
        }
    }
    
    var parameterText: String {
        switch self {
        case .strength:
            "STRENGTH"
        case .intellect:
            "INTELLECT"
        case .fun:
            "FUN"
        case .charm:
            "CHARM"
        case .sociability:
            "SOCIABILITY"
        }
    }
    
    var image: ImageResource {
        switch self {
        case .strength:
            return .strength
        case .intellect:
            return .intellect
        case .fun:
            return .fun
        case .charm:
            return .charm
        case .sociability:
            return .sociability
        }
    }
}

struct QuestViewModelItem {
    let id: String
    var image: UIImage?
    let imageId: String?
    let missionTitle: String
    let writer: String
    var rewardDic: [XpStat: Int]
    
    init(id: String, image: UIImage? = nil, imageId: String, missionTitle: String, writer: String, rewardDic: [XpStat: Int]) {
        self.id = id
        self.image = image
        self.imageId = imageId
        self.missionTitle = missionTitle
        self.writer = writer
        self.rewardDic = rewardDic
    }
    
    init(quest: Quest) {
        self.id = quest.questId
        self.image = nil
        self.imageId = quest.imageId
        self.missionTitle = quest.missionTitle
        self.writer = quest.writer
        self.rewardDic = [:]
        for reward in quest.rewardList {
            if reward.type == "XP" , let content = reward.content {
                self.rewardDic[XpStat(rawValue: content.lowercased()) ?? .strength] = reward.quantity
            }
        }
    }
    
    func totalRewardXP() -> Int {
        self.rewardDic.values.reduce(0, +)
    }
    
    static let mockImageId = "IMQU2024071520500801"
    
    static let mockData: QuestViewModelItem = QuestViewModelItem(
        id: "11",
        image: .checkmark,
        imageId: mockImageId,
        missionTitle: "아메리카노 15잔 마시기",
        writer: "이디야커피",
        rewardDic: [.charm: 30, .intellect: 100, .fun: 5]
    )
    
    static let mockQuestList: [QuestViewModelItem] = [
        QuestViewModelItem(
            id: "9f8aacc9-a221-491b-98c1-f9d7d35a67fb",
            image: .checkmark,
            imageId: mockImageId,
            missionTitle: "아메리카노 15잔 마시기",
            writer: "이디야커피",
            rewardDic: [:]
        ),
        QuestViewModelItem(
            id: "13",
            image: .checkmark,
            imageId: mockImageId,
            missionTitle: "카페라떼 1잔 마시기",
            writer: "투썸플레이스",
            rewardDic: [:]
        )
    ]
}
