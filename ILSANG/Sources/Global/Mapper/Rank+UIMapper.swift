//
//  Rank+UIMapper.swift
//  ILSANG
//
//  Created by Lee Jinhee on 8/25/25.
//

extension UserRank {
    func toRankItem() -> UserRankItem {
        UserRankItem(
            userId: userId,
            profileImageId: profileImageId,
            profileImage: nil,
            nickname: nickname,
            point: point,
            rank: rank,
            title: title,
            pointGap: pointGap
        )
    }
}

extension AreaRank {
    func toRankItem() -> AreaRankItem {
        AreaRankItem(
            areaCode: areaCode,
            areaName: areaName,
            point: point,
            imageIds: imageIds,
            rank: rank
        )
    }
}

extension AreaUserRank {
    func toRankItem() -> AreaUserRankItem {
        AreaUserRankItem(
            ranks: ranks.map { $0.toRankItem() },
            user: user?.toRankItem()
        )
    }
}
