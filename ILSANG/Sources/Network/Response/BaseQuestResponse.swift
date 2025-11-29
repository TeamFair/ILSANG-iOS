//
//  BaseQuestResponse.swift
//  ILSANG
//
//  Created by Lee Jinhee on 8/21/25.
//


struct BaseQuestResponse: Decodable {
    let questId: Int
    let writerName: String
    let questType: String? // "NORMAL" // TODO: 필드 추가 요청해둔 상태 > 확인 후 옵셔널 해제
    let repeatFrequency: String? // "DAILY" // TODO: 필드 추가 요청해둔 상태 > 확인 후 옵셔널 해제
    let title: String
    let mainImageId: String?
    let imageId: String
    let expireDate: String // "2025-08-21T11:53:17.556Z",
    let favoriteYn: Bool
    let rewards: [RewardResponse]
    let lastCompleteDate: String?
    let commercialAreaCode: String?
}

