//
//  UserCouponResponse.swift
//  ILSANG
//
//  Created by Lee Jinhee on 9/5/25.
//


import Foundation

struct UserCouponResponse: Decodable {
    let id: Int
    let useYn: Bool
    let expireYn: Bool
    let usedAt: String?
    let coupon: CouponResponse
    
    enum CodingKeys: String, CodingKey {
        case id
        case useYn = "couponUseYn"
        case expireYn = "couponExpireYn"
        case usedAt
        case coupon
    }
}

struct VerifyPasswordResponse: Decodable {
    let success: Bool
}
