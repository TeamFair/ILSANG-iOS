//
//  Point+UIMapping.swift
//  ILLSANG
//
//  Created by Lee Jinhee on 8/29/25.
//


extension PointCommercial {
    func toItem() -> PointCommercialItem {
        PointCommercialItem(
            topCommercialArea: topCommercialArea?.toItem(),
            totalOwnerContributions: totalOwnerContributions.map { $0.toItem() }
        )
    }
}
extension TotalOwnerContribution {
    func toItem() -> TotalOwnerContributionItem {
        TotalOwnerContributionItem(
            commercialAreaCode: commercialAreaCode,
            commercialAreaName: nil,
            point: point
        )
    }
}
extension TopCommercialArea {
    func toItem() -> TopCommercialAreaItem {
        TopCommercialAreaItem(
            commercialAreaCode: commercialAreaCode,
            commercialAreaName: nil,
            point: point,
            ownerContributionPercent: Int(ownerContributionPercent)
        )
    }
}

extension PointSummary {
    func toItem() -> PointSummaryItem {
        PointSummaryItem(
            topMetroAreaCode: topMetroAreaCode,
            topMetroAreaName: nil,
            topCommercialAreaCode: topCommercialAreaCode,
            topCommercialAreaName: nil,
            topContributionPoint: topContributionPoint
        )
    }
}
