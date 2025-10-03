//
//  Quest.swift
//  ILSANG
//
//  Created by Lee Jinhee on 7/18/24.
//

import Foundation

struct Quest {
    let id: Int
    let title: String
    let writer: String
    let questType: QuestType?
    let repeatFrequency: RepeatType?
    let rewards: [Reward]?
    let missions: [Mission]
    let coupons: [Coupon]
    let expireDate: Date?
    let imageId: String
    let mainImageId: String?
    let userRank: Int?
    let favoriteYn: Bool?
}
