//
//  HonorItem.swift
//  ILSANG
//
//  Created by Lee Jinhee on 5/13/25.
//

import SwiftUI

final class HonorItem: ObservableObject, Identifiable {
    let titleId: String
    var historyId: String?
    let title: String
    let acquisitionCondition: String
    let type: HonorGrade
    
    @Published var isSelected: Bool
    var isAcquired: Bool { historyId != nil }

    init(
        titleId: String,
        historyId: String?,
        isSelected: Bool,
        title: String,
        acquisitionCondition: String,
        type: HonorGrade
    ) {
        self.titleId = titleId
        self.historyId = historyId
        self.isSelected = isSelected
        self.title = title
        self.acquisitionCondition = acquisitionCondition
        self.type = type
    }
}
