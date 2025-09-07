//
//  QuestDetailViewModel.swift
//  ILSANG
//
//  Created by Lee Jinhee on 4/4/25.
//

import SwiftUI

@Observable
class QuestDetailViewModel {
    var quest: QuestViewModelItem
    var isLoading: Bool = false
    private let onFavorite: (QuestViewModelItem) -> Void

    var approvalDescription: String = "퀘스트를 수행하고\n인증 후, 포인트를 적립받으세요"
    
    private let questRepository: QuestRepositoryInterface
    
    init(quest: QuestViewModelItem, questRepository: QuestRepositoryInterface, onFavorite: @escaping (QuestViewModelItem) -> Void) {
        self.quest = quest
        self.questRepository = questRepository
        self.onFavorite = onFavorite
    }
    
    func updateChallengeImages() async {
        isLoading = true
        await quest.updateChallengeImages()
        isLoading = false
    }
    
    func toggleFavorite() {
        onFavorite(quest)
    }
}
