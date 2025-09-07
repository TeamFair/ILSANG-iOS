//
//  CouponResponse.swift
//  ILLSANG
//
//  Created by Lee Jinhee on 9/5/25.
//

import Foundation

struct CouponResponse: Decodable {
    let id: Int
    let name: String
    let imageId: String?
    let storeName: String?
    let description: String?
    let validFrom: String
    let validTo: String
    
    enum CodingKeys: String, CodingKey {
        case id = "couponId"
        case name
        case imageId
        case storeName
        case description
        case validFrom
        case validTo
    }
}
