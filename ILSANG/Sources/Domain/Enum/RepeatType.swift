//
//  RepeatType.swift
//  ILSANG
//
//  Created by Lee Jinhee on 12/7/24.
//

import SwiftUI

enum RepeatType: String, Hashable, CustomStringConvertible, CaseIterable {
    case daily
    case weekly
    case monthly
    
    init?(param: String) {
        self.init(rawValue: param.lowercased())
    }
    
    var description: String {
        switch self {
        case .daily:
            "일간"
        case .weekly:
            "주간"
        case .monthly:
            "월간"
        }
    }
    
    var fgColor: Color {
        switch self {
        case .daily, .weekly:
            Color.white
        case .monthly:
            Color.fgBadgeGreen
        }
    }
    
    var bgGradient: Gradient {
        switch self {
        case .daily:
            Gradient(colors: [.dailyLeft, .dailyRight])
        case .weekly:
            Gradient(colors: [.weeklyLeft, .weeklyRight])
        case .monthly:
            Gradient(colors: [.monthlyLeft, .monthlyRight])
        }
    }
    
    func toParam() -> String {
        return self.rawValue.uppercased()
    }
}
