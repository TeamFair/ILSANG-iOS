//
//  CommercialAreaRankResponse.swift
//  ILSANG
//
//  Created by Lee Jinhee on 8/25/25.
//


struct CommercialAreaRankResponse: Decodable {
    let commercialCode: String
    let areaName: String
    let point: Int
    let imageIds: [String]
    let rank: Int
    
    enum CodingKeys: String, CodingKey {
        case commercialCode
        case areaName
        case point
        case imageIds = "images"
        case rank
    }
}