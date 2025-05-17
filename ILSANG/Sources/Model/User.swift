//
//  UserModel.swift
//  ILSANG
//
//  Created by Kim Andrew on 6/21/24.
//

struct User: Decodable {
    let status: String
    let nickname: String
    let completeChallengeCount: Int
    let xpPoint: Int
    let profileImage: String?
    let title: Title?
}

struct Title: Decodable, Hashable {
    let id: String
    let name: String
    let type: String
    let condition: String
    let createdAt: String
}
