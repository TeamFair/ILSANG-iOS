//
//  CouponResponse+Mapping.swift
//  ILLSANG
//
//  Created by Lee Jinhee on 9/5/25.
//

import Foundation

extension CouponResponse: DomainConvertible {
    func toDomain() -> Coupon {
        Coupon(
            id: id,
            name: name,
            imageId: imageId,
            storeName: storeName,
            description: description,
            validFrom: validFrom.toISO8601Date() ?? .now,
            validTo: validTo.toISO8601Date() ?? .now
        )
    }
}

extension UserCouponResponse: DomainConvertible {
    func toDomain() -> UserCoupon {
        UserCoupon(
            id: id,
            useYn: useYn,
            expireYn: expireYn,
            usedAt: usedAt?.toISO8601Date(),
            coupon: coupon.toDomain()
        )
    }
}
