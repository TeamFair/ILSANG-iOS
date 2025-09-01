//
//  UserRankResponse.swift
//  ILSANG
//
//  Created by Lee Jinhee on 1/17/25.
//


struct UserRankResponse: Decodable {
    let userId: String
    let profileImageId: String?
    let nickname: String
    let point: Int?
    let rank: Int?
    let title: TitleResponse?
    let pointGap: Int?

    enum CodingKeys: String, CodingKey {
        case userId
        case profileImageId
        case nickname = "nickName"
        case point
        case rank
        case title
        case pointGap
    }
}
