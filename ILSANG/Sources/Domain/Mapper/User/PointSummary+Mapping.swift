//
//  PointSummary+Mapping.swift
//  ILLSANG
//
//  Created by Lee Jinhee on 8/29/25.
//


extension PointSummaryResponse: DomainConvertible {
    func toDomain() -> PointSummary {
        PointSummary(
            topMetroAreaCode: topMetroAreaCode,
            topCommercialAreaCode: topCommercialAreaCode,
            topContributionPoint: topContributionPoint
        )
    }
}
