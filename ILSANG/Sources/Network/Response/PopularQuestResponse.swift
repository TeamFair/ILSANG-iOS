//
//  PopularQuestResponse.swift
//  ILSANG
//
//  Created by Lee Jinhee on 8/21/25.
//


struct PopularQuestResponse: Decodable {
    let questId: Int
    let questType: String
    let repeatFrequency: String?
    let title: String
    let writerName: String
    let mainImageId: String?
    let imageId: String
    let expireDate: String
}
