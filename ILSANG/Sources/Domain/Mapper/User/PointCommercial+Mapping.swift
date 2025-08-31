//
//  PointCommercial+Mapping.swift
//  ILLSANG
//
//  Created by Lee Jinhee on 8/29/25.
//

import Foundation

extension PointCommercialResponse: DomainConvertible {
    func toDomain() -> PointCommercial {
        PointCommercial(
            topCommercialArea: topCommercialArea?.toDomain(),
            totalOwnerContributions: totalOwnerContributions.map { $0.toDomain() }
        )
    }
}

extension TopCommercialAreaReponse: DomainConvertible {
    func toDomain() -> TopCommercialArea {
        TopCommercialArea(
            commercialAreaCode: commercialAreaCode,
            point: point,
            ownerContributionPercent: ownerContributionPercent
        )
    }
}

extension TotalOwnerContributionResponse: DomainConvertible {
    func toDomain() -> TotalOwnerContribution {
        TotalOwnerContribution(
            commercialAreaCode: commercialAreaCode,
            point: point
        )
    }
}
