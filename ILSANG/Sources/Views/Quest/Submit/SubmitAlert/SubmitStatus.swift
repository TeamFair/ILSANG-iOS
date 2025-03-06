//
//  SubmitStatus.swift
//  ILSANG
//
//  Created by Lee Jinhee on 3/6/25.
//

import SwiftUI

enum SubmitStatus {
    case submit
    case complete
    case fail
    
    var title: String {
        switch self {
        case .submit:
            "제출 중이에요"
        case .complete:
            "제출이 완료됐어요"
        case .fail:
            "제출에 실패했어요"
        }
    }
    
    var subtitle: String {
        switch self {
        case .submit, .complete:
            ""
        case .fail:
            "다시 시도해보세요"
        }
    }
    
    var emoticon: String {
        switch self {
        case .submit, .complete:
            ""
        case .fail:
            "🥲"
        }
    }
    
    var icon: ImageResource {
        switch self {
        case .submit:
            return .ellipsis
        case .complete:
            return .check
        case .fail:
            return .xmark
        }
    }
    
    var iconWidth: CGFloat {
        switch self {
        case .submit:
            return 35
        case .complete:
            return 31
        case .fail:
            return 24
        }
    }
    
    var color: IconColor {
        switch self {
        case .submit:
            return .blue
        case .complete:
            return .green
        case .fail:
            return .red
        }
    }
}
