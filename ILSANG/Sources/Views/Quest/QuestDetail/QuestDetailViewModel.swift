//
//  QuestDetailViewModel.swift
//  ILSANG
//
//  Created by Lee Jinhee on 4/4/25.
//

import SwiftUI

class QuestDetailViewModel: ObservableObject {
    var quest: QuestItem
    var isLoading: Bool = false
    @Published var showCouponRewardView: Bool = false
    private var onFavorite: ((QuestItem) -> Void)?

    var approvalDescription: String = "퀘스트를 수행하고\n인증 후, 포인트를 적립받으세요"
    var approvalButtonAble: Bool {
        if quest.questType == .repeat { // 반복 퀘스트인 경우
            return !quest.isRepeatDisabled
        } else {
            return true // 일반 퀘스트는 항상 활성화
        }
    }
    private let questRepository: QuestRepositoryInterface
    
    init(quest: QuestItem, questRepository: QuestRepositoryInterface, onFavorite: @escaping (QuestItem) -> Void) {
        self.quest = quest
        self.questRepository = questRepository
        self.onFavorite = onFavorite
        Log("🗑️ QuestDetailViewModel init")
    }
    
    deinit {
        onFavorite = nil
        Log("🗑️ QuestDetailViewModel deinit")
    }
    
    func updateChallengeImages() async {
        isLoading = true
        await quest.updateChallengeImages()
        isLoading = false
    }
    
    func toggleFavorite() {
        onFavorite?(quest)
    }
}
