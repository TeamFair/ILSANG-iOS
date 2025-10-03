//
//  AreaUserRankResponse+Mapping.swift
//  ILSANG
//
//  Created by Lee Jinhee on 8/25/25.
//


extension AreaUserRankResponse: DomainConvertible {
    func toDomain() -> AreaUserRank {
        AreaUserRank(
            ranks: ranks.map { $0.toDomain() },
            user: user.toDomainOrNil()
        )
    }
}
