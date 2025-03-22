//
//  SubmitStatus.swift
//  ILSANG
//
//  Created by Lee Jinhee on 3/6/25.
//

import SwiftUI

enum SubmitStatus {
    case inProgress
    case complete
    case fail
    case retry
    
    var title: String {
        switch self {
        case .inProgress: "제출중이에요"
        case .complete: "제출이 완료됐어요"
        case .fail: "제출에 실패했어요"
        case .retry: "다시 한번 생각해 보세요!"
        }
    }
    
    var subtitle: String {
        switch self {
        case .inProgress, .complete: ""
        case .fail: "다시 시도해보세요🥲"
        case .retry: "정답을 맞힐 때까지 도전할 수 있어요!"
        }
    }
    
    var iconWidth: CGFloat { 60.0 }
}
