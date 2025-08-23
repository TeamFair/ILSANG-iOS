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
    var showImageSheetView: Bool = false
    var selectedImage: UIImage = .logo
    private let onUpdate: (QuestViewModelItem) -> Void

    var approvalDescription: String = "퀘스트를 수행하고\n인증 후, 포인트를 적립받으세요"
    
    private let questRepository: QuestRepositoryInterface
    
    init(quest: QuestViewModelItem, questRepository: QuestRepositoryInterface, onUpdate: @escaping (QuestViewModelItem) -> Void) {
        self.quest = quest
        self.questRepository = questRepository
        self.onUpdate = onUpdate
    }
    
    func fetchQuestDetail() async {
        isLoading = true
        
        do {
            await quest.updateChallengeImages()

            let questDetail = try await questRepository.getQuestDetail(questId: quest.id)
                .get()
                .toQuestItem()
            await questDetail.updateChallengeImages()
            self.quest = questDetail
        } catch {
            Log("퀘스트 상세정보 불러오기 실패")
        }
        
        isLoading = false
    }
    
    func onImageTapped(image: UIImage) {
        selectedImage = image
        showImageSheetView.toggle()
    }
    
    func toggleFavorite() {
        onUpdate(quest)
    }
}
