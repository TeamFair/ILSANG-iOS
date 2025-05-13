//
//  HonorItem.swift
//  ILSANG
//
//  Created by Lee Jinhee on 4/27/25.
//


import SwiftUI

final class HonorItem: ObservableObject, Identifiable {
    let id = UUID()
    @Published var isSelected: Bool
    let title: String
    let acquisitionCondition: String
    let isAcquired: Bool
    let type: HonorGrade
    
    init(
        isSelected: Bool,
        title: String,
        acquisitionCondition: String,
        isAcquired: Bool,
        type: HonorGrade
    ) {
        self.isSelected = isSelected
        self.title = title
        self.acquisitionCondition = acquisitionCondition
        self.isAcquired = isAcquired
        self.type = type
    }
}