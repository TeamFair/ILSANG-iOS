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
            type: type.flatMap { CouponSettingType(type: $0) },
            validFrom: validFrom?.toISO8601Date(),
            validTo: validTo?.toISO8601Date()
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
