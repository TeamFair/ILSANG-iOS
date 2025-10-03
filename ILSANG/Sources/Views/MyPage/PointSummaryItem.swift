//
//  PointSummaryItem.swift
//  ILLSANG
//
//  Created by Lee Jinhee on 8/29/25.
//

import Foundation

@Observable
class PointSummaryItem: Identifiable {
    let topMetroAreaCode: String
    var topMetroAreaName: String?
    let topCommercialAreaCode: String
    var topCommercialAreaName: String?
    let topContributionPoint: Int
    
    init(topMetroAreaCode: String, topMetroAreaName: String? = nil, topCommercialAreaCode: String, topCommercialAreaName: String?, topContributionPoint: Int) {
        self.topMetroAreaCode = topMetroAreaCode
        self.topMetroAreaName = topMetroAreaName
        self.topCommercialAreaCode = topCommercialAreaCode
        self.topCommercialAreaName = topCommercialAreaName
        self.topContributionPoint = topContributionPoint
    }
}
