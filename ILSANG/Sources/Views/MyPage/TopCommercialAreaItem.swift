//
//  TopCommercialAreaItem.swift
//  ILLSANG
//
//  Created by Lee Jinhee on 8/29/25.
//

import Foundation

@Observable
class PointCommercialItem: Identifiable {
    let topCommercialArea: TopCommercialAreaItem?
    let totalOwnerContributions: [TotalOwnerContributionItem]
    
    init(topCommercialArea: TopCommercialAreaItem?, totalOwnerContributions: [TotalOwnerContributionItem]) {
        self.topCommercialArea = topCommercialArea
        self.totalOwnerContributions = totalOwnerContributions
    }
}

@Observable
class TopCommercialAreaItem {
    let commercialAreaCode: String
    var commercialAreaName: String?
    let point: Int
    let ownerContributionPercent: Int
    
    init(commercialAreaCode: String, commercialAreaName: String?, point: Int, ownerContributionPercent: Int) {
        self.commercialAreaCode = commercialAreaCode
        self.commercialAreaName = commercialAreaName
        self.point = point
        self.ownerContributionPercent = ownerContributionPercent
    }
}


@Observable
class TotalOwnerContributionItem: Hashable {
    let commercialAreaCode: String
    var commercialAreaName: String?
    let point: Int
    
    init(commercialAreaCode: String, commercialAreaName: String?, point: Int) {
        self.commercialAreaCode = commercialAreaCode
        self.commercialAreaName = commercialAreaName
        self.point = point
    }
    static func == (lhs: TotalOwnerContributionItem, rhs: TotalOwnerContributionItem) -> Bool {
        lhs.commercialAreaCode == rhs.commercialAreaCode
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(commercialAreaCode)
    }
}

extension Array where Element == TotalOwnerContributionItem {
    func pointRatios() -> [Int] {
        let total = self.reduce(0) { $0 + $1.point }
        guard total > 0 else {
            return []
        }
        
        // 1차: 기본 비율 계산 (반올림)
        var ratios = self.map { item in
            Int(round(Double(item.point) / Double(total) * 100))
        }
        
        // 합이 100이 안 될 수 있으므로 보정
        var diff = 100 - ratios.reduce(0, +)
        
        // diff > 0 이면 일부 아이템에 +1, diff < 0 이면 일부 아이템에서 -1
        var index = 0
        while diff != 0 && !ratios.isEmpty {
            if diff > 0 {
                ratios[index % ratios.count] += 1
                diff -= 1
            } else {
                if ratios[index % ratios.count] > 0 { // 0 미만 방지
                    ratios[index % ratios.count] -= 1
                    diff += 1
                }
            }
            index += 1
        }
        
        return ratios
    }
}
