//
//  AreaResponse+Mapping.swift
//  ILSANG
//
//  Created by Lee Jinhee on 8/27/25.
//


extension MetroAreaResponse {
    func toDomain() -> MetroArea {
        MetroArea(
            code: code,
            areaName: areaName,
            commercialAreas: commercialAreas.map { $0.toDomain() }
        )
    }
}

extension CommercialAreaResponse {
    func toDomain() -> CommercialArea {
        CommercialArea(
            code: code,
            areaName: areaName,
            metroAreaCode: metroAreaCode
        )
    }
}
