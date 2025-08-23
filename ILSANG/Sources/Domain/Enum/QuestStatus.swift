//
//  QuestStatus.swift
//  ILSANG
//
//  Created by Lee Jinhee on 12/7/24.
//

import Foundation

enum QuestStatus: String, CaseIterable {
    case `default`
    case `repeat`
    case event
    case completed
    
    var headerText: String {
        switch self {
        case .default:
            "기본"
        case .repeat:
            "반복"
        case .event:
            "이벤트"
        case .completed:
            "완료"
        }
    }
    
    var emptyTitle: String {
        switch self {
        case .default, .repeat, .event:
            "퀘스트를 모두 완료하셨어요!"
        case .completed:
            "완료된 퀘스트가 없어요"
        }
    }
    
    var emptySubTitle: String {
        switch self {
        case .default, .repeat, .event:
            "상상할 수 없는 퀘스트를 준비 중이니\n다음 업데이트를 기대해 주세요!"
        case .completed:
            "퀘스트를 수행하러 가볼까요?"
        }
    }
}
