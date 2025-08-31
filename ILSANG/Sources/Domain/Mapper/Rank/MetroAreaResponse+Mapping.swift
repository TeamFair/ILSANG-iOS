//
//  MetroAreaResponse+Mapping.swift
//  ILSANG
//
//  Created by Lee Jinhee on 8/25/25.
//


extension MetroAreaRankResponse: DomainConvertible {
    func toDomain() -> AreaRank {
        AreaRank(
            areaCode: metroCode,
            areaName: areaName,
            point: point,
            imageIds: imageIds,
            rank: rank
        )
    }
}
