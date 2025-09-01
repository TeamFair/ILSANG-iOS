//
//  UserRankResponse+Mapping.swift
//  ILSANG
//
//  Created by Lee Jinhee on 8/25/25.
//


extension UserRankResponse: DomainConvertible {
    func toDomain() -> UserRank {
        UserRank(
            userId: userId,
            profileImageId: profileImageId,
            nickname: nickname,
            point: point ?? 0,
            rank: rank ?? 0,
            title: title,
            pointGap: pointGap
        )
    }
    
    func toDomainOrNil() -> UserRank? {
        guard !(point == nil && rank == nil) else { return nil }
        return toDomain()
    }
}
