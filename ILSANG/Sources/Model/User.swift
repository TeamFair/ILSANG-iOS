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
}
