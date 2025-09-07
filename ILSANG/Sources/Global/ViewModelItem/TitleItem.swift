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
