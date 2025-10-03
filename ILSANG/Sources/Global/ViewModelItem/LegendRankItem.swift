//
//  LegendRankItem.swift
//  ILLSANG
//
//  Created by Lee Jinhee on 9/11/25.
//

import UIKit

class LegendRankItem: ObservableObject {
    let userId: String
    let nickname: String
    @Published var profileImage: UIImage?
    let profileImageId: String?
    let rank: Int
    let point: Int?
    let title: UserTitle?
    
    init(userId: String, nickname: String, profileImage: UIImage? = nil, profileImageId: String?, rank: Int, point: Int?, title: UserTitle?) {
        self.userId = userId
        self.nickname = nickname
        self.profileImage = profileImage
        self.profileImageId = profileImageId
        self.rank = rank
        self.point = point
        self.title = title
    }
}
