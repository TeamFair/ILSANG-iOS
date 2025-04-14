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

    var approvalDescription: String {
        switch quest.missionType {
        case .quiz:
            "퀘스트를 지금 인증하고,\n보상을 적립받으세요!"
        case .image:
            "퀘스트를 수행하셨나요?\n인증 후 포인트를 적립받으세요"
        }
    }
    
    private let questNetwork: QuestNetwork
    
    init(quest: QuestViewModelItem, questNetwork: QuestNetwork, onUpdate: @escaping (QuestViewModelItem) -> Void) {
        self.quest = quest
        self.questNetwork = questNetwork
        self.onUpdate = onUpdate
    }
    
    func fetchQuestDetail() async {
        isLoading = true
        
        do {
            let questDetail = try await questNetwork.getQuestDetail(questId: quest.id).get().data
            
            // Model 객체에서 상태 업데이트
            await quest.updateChallengeImages(
                challengeImageIds: questDetail.topLikeChallenges,
                customerRank: questDetail.customerRank
            )
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
