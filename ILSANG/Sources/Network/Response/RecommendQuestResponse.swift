//
//  RecommendQuestResponse.swift
//  ILSANG
//
//  Created by Lee Jinhee on 8/21/25.
//


struct RecommendQuestResponse: Decodable {
    let questId: Int
    let title: String
    let writerName: String
    let mainImageId: String?
    let imageId: String
}
