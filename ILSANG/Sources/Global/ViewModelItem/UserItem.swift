//
//  UserItem.swift
//  ILLSANG
//
//  Created by Lee Jinhee on 9/11/25.
//

import UIKit

class UserItem: ObservableObject {
    let id: String
    let email: String
    let channel: String
    let status: String
    let nickname: String
    let profileImageId: String?
    @Published var profileImage: UIImage?
    let commercialAreaCode: String?
    let title: UserTitle?
    
    init(id: String, email: String, channel: String, status: String, nickname: String, profileImageId: String?, profileImage: UIImage? = nil, commercialAreaCode: String?, title: UserTitle?) {
        self.id = id
        self.email = email
        self.channel = channel
        self.status = status
        self.nickname = nickname
        self.profileImageId = profileImageId
        self.profileImage = profileImage
        self.commercialAreaCode = commercialAreaCode
        self.title = title
    }
}
