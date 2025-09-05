//
//  Coupon.swift
//  ILSANG
//
//  Created by Lee Jinhee on 9/5/25.
//

import Foundation

struct Coupon {
    let id: Int
    let couponType: CouponType
    let name: String
    let imageId: String?
    let storeName: String
    let description: String?
    let validFrom: Date
    let validTo: Date
}
