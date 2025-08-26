//
//  AreaUserRankResponse.swift
//  ILSANG
//
//  Created by Lee Jinhee on 8/25/25.
//


struct AreaUserRankResponse: Decodable {
    let ranks: [UserRankResponse]
    let user: UserRankResponse
}
