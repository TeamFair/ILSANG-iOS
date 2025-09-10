//
//  BannerQuestResponse.swift
//  ILLSANG
//
//  Created by Lee Jinhee on 9/7/25.
//


struct BannerQuestResponse: Decodable {
    let questId: Int
    let title: String
    let writerName: String
    let mainImageId: String?
    let imageId: String
    let expireDate: String
    let rewards: [RewardResponse]
    let questType: String
    let repeatFrequency: String?
}
