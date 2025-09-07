//
//  UserCoupon.swift
//  ILSANG
//
//  Created by Lee Jinhee on 9/5/25.
//

import Foundation

struct UserCoupon {
    let id: Int
    let useYn: Bool
    let expireYn: Bool
    let usedAt: Date?
    let coupon: Coupon
}
