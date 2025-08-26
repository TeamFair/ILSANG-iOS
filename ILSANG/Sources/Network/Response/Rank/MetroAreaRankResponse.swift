//
//  MetroAreaRankResponse.swift
//  ILSANG
//
//  Created by Lee Jinhee on 8/25/25.
//


struct MetroAreaRankResponse: Decodable {
    let metroCode: String
    let areaName: String
    let point: Int
    let imageIds: [String]
    let rank: Int
    
    enum CodingKeys: String, CodingKey {
        case metroCode
        case areaName
        case point
        case imageIds = "images"
        case rank
    }
}
