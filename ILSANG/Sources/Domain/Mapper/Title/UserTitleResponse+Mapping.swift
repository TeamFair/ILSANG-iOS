//
//  UserTitleResponse+Mapping.swift
//  ILLSANG
//
//  Created by Lee Jinhee on 9/7/25.
//

extension UserTitleResponse: DomainConvertible {
    func toDomain() -> UserTitle {
        UserTitle(
            titleHistoryId: titleHistoryId,
            name: name,
            grade: HonorGrade(rawValue: grade) ?? .standard,
            createdAt: createdAt?.toISO8601Date()
        )
    }
}
