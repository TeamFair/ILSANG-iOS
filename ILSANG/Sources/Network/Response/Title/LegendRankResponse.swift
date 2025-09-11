//
//  LegendRankResponse.swift
//  ILSANG
//
//  Created by Lee Jinhee on 9/11/25.
//


struct LegendRankResponse: Decodable {
    let userId: String
    let profileImageId: String?
    let nickName: String
    let point: Int?
    let rank: Int?
    let title: UserTitleResponse?
}
