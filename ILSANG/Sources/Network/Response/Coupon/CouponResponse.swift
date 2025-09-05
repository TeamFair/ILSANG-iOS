//
//  CouponResponse.swift
//  ILLSANG
//
//  Created by Lee Jinhee on 9/5/25.
//

import Foundation

struct CouponResponse: Decodable {
    let id: Int
    let couponType: CouponType
    let name: String
    let imageId: String?
    let storeName: String
    let description: String?
    let validFrom: String
    let validTo: String
    
    enum CodingKeys: String, CodingKey {
        case id = "couponId"
        case couponType
        case name
        case imageId
        case storeName
        case description
        case validFrom
        case validTo
    }
}

enum CouponType: String, Decodable {
    case week, month, season
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = try container.decode(String.self).lowercased()
        
        guard let type = CouponType(rawValue: raw) else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid coupon type: \(raw)"
            )
        }
        self = type
    }
}
