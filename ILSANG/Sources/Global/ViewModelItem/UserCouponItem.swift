//
//  UserCouponItem.swift
//  ILSANG
//
//  Created by Lee Jinhee on 9/5/25.
//

import Foundation

struct UserCouponItem: Identifiable {
    let id: Int
    let useYn: Bool
    let expireYn: Bool
    let usedAt: Date?
    let coupon: CouponItem
}

extension UserCouponItem {
    var expireAtText: String {
        return coupon.validTo.toDisplayFormat(.full) + " 까지"
    }
    
    var redeemedText: String {
        if expireYn {
            return "기간만료"
        } else {
            if let usedAt {
                return "사용완료(" + usedAt.toDisplayFormat(.short) + " 사용)"
            }
            return ""
        }
    }
    
    static let mockData: [UserCouponItem] = [
        UserCouponItem(
            id: 1,
            useYn: false,
            expireYn: false,
            usedAt: nil,
            coupon: CouponItem(
                id: 101,
                name: "1주일 무료 이용권",
                imageId: "",
                image: nil,
                storeName: "일상 스토어",
                description: "7일 동안 자유롭게 사용할 수 있는 이용권",
                validFrom: .now,
                validTo: .now
            )
        ),
        UserCouponItem(
            id: 2,
            useYn: true,
            expireYn: false,
            usedAt: Date(),
            coupon: CouponItem(
                id: 102,
                name: "1개월 할인 쿠폰",
                imageId: "",
                image: nil,
                storeName: "일상 마켓",
                description: "30일 동안 사용할 수 있는 특별 할인 쿠폰",
                validFrom: .now,
                validTo: .now
            )
        ),
        UserCouponItem(
            id: 3,
            useYn: false,
            expireYn: true,
            usedAt: nil,
            coupon: CouponItem(
                id: 103,
                name: "시즌 특별 쿠폰",
                imageId: "",
                image: nil,
                storeName: "일상 가게",
                description: "시즌 한정으로 제공되는 특별 혜택 쿠폰",
                validFrom: .now,
                validTo: .now
            )
        ),
        UserCouponItem(
            id: 4,
            useYn: true,
            expireYn: true,
            usedAt: nil,
            coupon: CouponItem(
                id: 103,
                name: "시즌 특별 쿠폰",
                imageId: "",
                image: nil,
                storeName: "일상 가게",
                description: "시즌 한정으로 제공되는 특별 혜택 쿠폰",
                validFrom: .now,
                validTo: .now
            )
        )
    ]
}
