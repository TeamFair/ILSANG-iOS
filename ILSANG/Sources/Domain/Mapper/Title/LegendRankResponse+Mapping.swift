//
//  LegendRankResponse+Mapping.swift
//  ILLSANG
//
//  Created by Lee Jinhee on 9/11/25.
//

extension LegendRankResponse: DomainConvertible {
    func toDomain() -> LegendRank {
        LegendRank(
            userId: userId,
            profileImageId: profileImageId,
            nickName: nickName,
            point: point,
            rank: rank,
            title: title?.toDomain()
        )
    }
}
