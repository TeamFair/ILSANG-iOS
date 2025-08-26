//
//  Rank+UIMapper.swift
//  ILSANG
//
//  Created by Lee Jinhee on 8/25/25.
//

extension UserRank {
    func toRankItem() -> UserRankViewModelItem {
        UserRankViewModelItem(
            userId: userId,
            profileImageId: profileImageId,
            profileImage: nil,
            nickname: nickname,
            point: point,
            rank: rank,
            title: title
        )
    }
}

extension AreaRank {
    func toRankItem() -> AreaRankViewModelItem {
        AreaRankViewModelItem(
            areaCode: areaCode,
            areaName: areaName,
            point: point,
            imageIds: imageIds,
            rank: rank
        )
    }
}

extension AreaUserRank {
    func toRankItem() -> AreaUserRankViewModelItem {
        AreaUserRankViewModelItem(
            ranks: ranks.map { $0.toRankItem() },
            user: user?.toRankItem()
        )
    }
}
