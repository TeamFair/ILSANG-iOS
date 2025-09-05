//
//  CouponItem.swift
//  ILSANG
//
//  Created by Lee Jinhee on 9/5/25.
//


import SwiftUI

struct CouponItem {
    let id: Int
    let couponType: CouponType
    let name: String
    let imageId: String?
    var image: UIImage?
    let storeName: String
    let description: String?
    let validFrom: Date
    let validTo: Date
}