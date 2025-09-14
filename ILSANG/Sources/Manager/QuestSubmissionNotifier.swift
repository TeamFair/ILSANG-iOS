//
//  QuestStateManager.swift
//  ILSANG
//
//  Created by Lee Jinhee on 9/12/25.
//


import SwiftUI

final class QuestSubmissionNotifier: ObservableObject {
    // 갱신 트리거 - 이 값이 변경되면 구독하고 있는 뷰들을 갱신
    @Published var refreshTrigger = UUID()
    
    init() {}
        
    /// 퀘스트 제출 완료 시 호출
    func markQuestAsSubmitted() {
        // 구독자에게 갱신 신호 전송
        refreshTrigger = UUID()
        
        Log("🎯 Quest submitted: triggering refresh...")
    }
}
