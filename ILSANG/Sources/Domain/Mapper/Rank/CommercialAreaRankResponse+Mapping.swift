//
//  CommercialAreaRankResponse+Mapping.swift
//  ILSANG
//
//  Created by Lee Jinhee on 8/25/25.
//


extension CommercialAreaRankResponse: DomainConvertible {
    func toDomain() -> AreaRank {
        AreaRank(
            areaCode: commercialCode,
            areaName: areaName,
            point: point,
            imageIds: imageIds,
            rank: rank
        )
    }
}
