//
//  FavoriteService.swift
//  ILSANG
//
//  Created by Lee Jinhee on 4/9/25.
//

import Foundation

protocol FavoriteServiceInterface {
    func toggle(quest: QuestViewModelItem)
}

final class FavoriteService: FavoriteServiceInterface {
    private var debounceTasks: [Int: Task<Void, Never>] = [:]
    private var originalState: [Int: Bool] = [:]
    
    private let debounceDelay: TimeInterval = 1.0
    private let favoriteNetwork: FavoriteNetwork
    
    init(favoriteNetwork: FavoriteNetwork) {
        self.favoriteNetwork = favoriteNetwork
    }
    
    func toggle(quest: QuestViewModelItem) {
        let questId = quest.id
        
        // 원래 상태 저장 (첫 토글일 때만)
        if originalState[questId] == nil {
            originalState[questId] = quest.favoriteYn
        }
        
        // UI 즉시 반영
        quest.favoriteYn.toggle()
        
        // debounce task 취소 및 재설정
        debounceTasks[questId]?.cancel()
        debounceTasks[questId] = Task { [weak self] in
            let nanoseconds = UInt64((self?.debounceDelay ?? 1.0) * 1_000_000_000)
            try? await Task.sleep(nanoseconds: nanoseconds)
            await self?.sendUpdate(for: quest)
            self?.debounceTasks[questId] = nil
        }
    }
    
    @MainActor
    private func sendUpdate(for quest: QuestViewModelItem) async {
        let questId = quest.id
        guard let original = originalState[questId] else { return }
        originalState[questId] = nil
        
        guard original != quest.favoriteYn else { return }
        
        let success: Bool
        if quest.favoriteYn {
            success = await favoriteNetwork.post(questId: quest.id)
        } else {
            success = await favoriteNetwork.delete(questId: quest.id)
        }
        
        if !success {
            // 실패하면 상태 복구
            quest.favoriteYn.toggle()
        }
    }
}
