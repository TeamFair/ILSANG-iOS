//
//  Coupon+UIMapper.swift
//  ILLSANG
//
//  Created by Lee Jinhee on 9/5/25.
//

import Foundation

extension Coupon {
    func toCoupon() -> CouponItem {
        CouponItem(
            id: id,
            name: name,
            imageId: imageId,
            image: nil,
            storeName: storeName,
            description: description,
            type: type,
            validFrom: validFrom,
            validTo: validTo
        )
    }
}

extension UserCoupon {
    func toUserCoupon() -> UserCouponItem {
        UserCouponItem(
            id: id,
            useYn: useYn,
            expireYn: expireYn,
            usedAt: usedAt,
            coupon: coupon.toCoupon()
        )
    }
}
