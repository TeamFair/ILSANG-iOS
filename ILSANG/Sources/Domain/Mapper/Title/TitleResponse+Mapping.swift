//
//  TitleResponse+Mapping.swift
//  ILLSANG
//
//  Created by Lee Jinhee on 9/7/25.
//

extension TitleResponse: DomainConvertible {
    func toDomain() -> Title {
        Title(
            id: id,
            name: name,
            type: type,
            grade: HonorGrade(rawValue: grade) ?? .standard,
            condition: condition
        )
    }
}
