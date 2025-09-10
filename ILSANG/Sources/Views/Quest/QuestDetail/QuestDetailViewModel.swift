//
//  QuestDetailViewModel.swift
//  ILSANG
//
//  Created by Lee Jinhee on 4/4/25.
//

import SwiftUI

class QuestDetailViewModel: ObservableObject {
    var quest: QuestViewModelItem
    var isLoading: Bool = false
    private var onFavorite: ((QuestViewModelItem) -> Void)?

    var approvalDescription: String = "퀘스트를 수행하고\n인증 후, 포인트를 적립받으세요"
    
    private let questRepository: QuestRepositoryInterface
    
    init(quest: QuestViewModelItem, questRepository: QuestRepositoryInterface, onFavorite: @escaping (QuestViewModelItem) -> Void) {
        self.quest = quest
        self.questRepository = questRepository
        self.onFavorite = onFavorite
        print("🗑️ QuestDetailViewModel init")
    }
    
    deinit {
        onFavorite = nil
        print("🗑️ QuestDetailViewModel deinit")
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
