//
//  User+UIMapping.swift
//  ILLSANG
//
//  Created by Lee Jinhee on 9/11/25.
//


extension User {
    func toItem() -> UserItem {
        return UserItem(
            id: id,
            email: email,
            channel: channel,
            status: status,
            nickname: nickname,
            profileImageId: profileImageId,
            profileImage: nil,
            commercialAreaCode: commercialAreaCode,
            title: title
        )
    }
}
