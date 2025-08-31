//
//  PointCommercial.swift
//  ILLSANG
//
//  Created by Lee Jinhee on 8/29/25.
//

import Foundation

struct PointCommercial {
    let topCommercialArea: TopCommercialArea?
    let totalOwnerContributions: [TotalOwnerContribution]
}

struct TopCommercialArea {
    let commercialAreaCode: String
    let point: Int
    let ownerContributionPercent: Double
}

struct TotalOwnerContribution: Equatable {
    let commercialAreaCode: String
    let point: Int
}
