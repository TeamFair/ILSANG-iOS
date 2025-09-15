//
//  CouponItem.swift
//  ILSANG
//
//  Created by Lee Jinhee on 9/5/25.
//


import SwiftUI

struct CouponItem {
    let id: Int
    let name: String
    let imageId: String?
    var image: UIImage?
    let storeName: String?
    let description: String?
    let validFrom: Date?
    let validTo: Date?
    
    var expireAtText: String {
        if let expireAtString = validTo?.toDisplayFormat(.full) {
            return expireAtString + "까지"
        } else {
            return ""
        }
    }
    
    static var mockData: CouponItem = CouponItem(
        id: 0,
        name: "쿠폰",
        imageId: nil,
        image: nil,
        storeName: "가게명",
        description: nil,
        validFrom: .now,
        validTo: .now
    )
}
