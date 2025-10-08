//
//  SeasonResponse+Mapping.swift
//  ILLSANG
//
//  Created by Lee Jinhee on 10/4/25.
//

import Foundation

extension SeasonResponse: DomainConvertible {
    func toDomain() -> Season {
        Season(
            id: id,
            seasonNumber: seasonNumber,
            startDate: startDate,
            endDate: endDate
        )
    }
}
