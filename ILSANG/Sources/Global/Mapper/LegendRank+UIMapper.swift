//
//  LegendRank+UIMapper.swift
//  ILLSANG
//
//  Created by Lee Jinhee on 9/11/25.
//

extension LegendRank {
    func toItem() -> LegendRankItem? {
        guard let nickName, let rank else {
            return nil
        }
        
        return LegendRankItem(
            userId: userId,
            nickname: nickName,
            profileImage: nil,
            profileImageId: profileImageId,
            rank: rank,
            point: point,
            title: title
        )
    }
}
