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

struct QuestViewModelItem {
    let id: String
    var image: UIImage?
    let imageId: String?
    let missionTitle: String
    let writer: String
    let reward: Int
    
    init(id: String, image: UIImage? = nil, imageId: String, missionTitle: String, writer: String, reward: Int) {
        self.id = id
        self.image = image
        self.imageId = imageId
        self.missionTitle = missionTitle
        self.writer = writer
        self.reward = reward
    }
    
    init(quest: Quest) {
        self.id = quest.questId
        self.image = nil
        self.imageId = quest.imageId
        self.missionTitle = quest.missionTitle
        self.writer = quest.writer
        self.reward = quest.quantity
    }
    
    static let mockImageId = "IMQU2024071520500801"
    
    static let mockData: QuestViewModelItem = QuestViewModelItem(
        id: "11",
        image: .checkmark,
        imageId: mockImageId,
        missionTitle: "아메리카노 15잔 마시기",
        writer: "이디야커피",
        reward: 50
    )
    
    static let mockQuestList: [QuestViewModelItem] = [
        QuestViewModelItem(
            id: "9f8aacc9-a221-491b-98c1-f9d7d35a67fb",
            image: .checkmark,
            imageId: mockImageId,
            missionTitle: "아메리카노 15잔 마시기",
            writer: "이디야커피",
            reward: 50
        ),
        QuestViewModelItem(
            id: "13",
            image: .checkmark,
            imageId: mockImageId,
            missionTitle: "카페라떼 1잔 마시기",
            writer: "투썸플레이스",
            reward: 150
        )
    ]
}
