//
//  TitleItem.swift
//  ILLSANG
//
//  Created by Lee Jinhee on 9/7/25.
//

import Foundation

final class TitleItem: ObservableObject, Identifiable, Equatable {
    static func == (lhs: TitleItem, rhs: TitleItem) -> Bool {
        lhs.titleId == rhs.titleId && lhs.historyId == rhs.historyId
    }
    
    let titleId: String
    let name: String
    let condition: String
    let grade: HonorGrade
    
    let historyId: Int?   // 획득 기록 ID (nil → 미획득)
    var isAcquired: Bool { historyId != nil }
    
    @Published var isSelected: Bool
    
    var displayType: DisplayType {
        // 1등, 2등, 3등 => 이미지
        if let match = condition.range(of: #"(\d+)등"#, options: .regularExpression) {
            let rankStr = condition[match].replacingOccurrences(of: "등", with: "")
            if let rank = Int(rankStr), (1...3).contains(rank) {
                return .image("rank\(rank)")
            }
        }
        
        // 범위 => 텍스트
        if let match = condition.range(of: #"(\d+)~(\d+)등"#, options: .regularExpression) {
            let rangeText = String(condition[match])
                .replacingOccurrences(of: "등", with: "")
                .replacingOccurrences(of: "~", with: "     ~     ") // 공백 추가
            return .text(rangeText) // 예: "4     ~     10"
        }
        
        // 그 외
        return .text(condition)
    }
    
    enum DisplayType {
        case image(String) // 이미지 이름
        case text(String)  // 보여줄 텍스트
    }
    
    init(
        titleId: String,
        name: String,
        condition: String,
        grade: HonorGrade,
        historyId: Int? = nil,
        isSelected: Bool = false
    ) {
        self.titleId = titleId
        self.name = name
        self.condition = condition
        self.grade = grade
        self.historyId = historyId
        self.isSelected = isSelected
    }
}
