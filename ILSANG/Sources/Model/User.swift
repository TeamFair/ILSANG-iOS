//
//  UserModel.swift
//  ILSANG
//
//  Created by Kim Andrew on 6/21/24.
//

import Foundation

struct User: Decodable {
    let id: String
    let email: String
    let channel: String
    let status: String
    let nickname: String
    let profileImageId: String?
    let commercialAreaCode: String?
    let title: UserTitleResponse?
}
