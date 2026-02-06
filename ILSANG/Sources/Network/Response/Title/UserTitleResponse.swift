//
//  UserTitleResponse.swift
//  ILSANG
//
//  Created by Lee Jinhee on 8/18/25.
//

struct UserTitleResponse: Decodable {
    let titleHistoryId: Int?
    let name, grade: String
    let type: String?
    let createdAt: String?
}
