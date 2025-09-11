//
//  User+Mapping.swift
//  ILLSANG
//
//  Created by Lee Jinhee on 9/11/25.
//


extension UserResponse: DomainConvertible {
    func toDomain() -> User {
        User(
            id: id,
            email: email,
            channel: channel,
            status: status,
            nickname: nickname,
            profileImageId: profileImageId,
            commercialAreaCode: commercialAreaCode,
            title: title?.toDomain()
        )
    }
}
