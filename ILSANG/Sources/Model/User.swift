//
//  UserModel.swift
//  ILSANG
//
//  Created by Kim Andrew on 6/21/24.
//

import Foundation

struct User: Decodable {
    let email: String
    let channel: String
    let status: String
    let nickname: String
    let profileImageId: String?
    let commercialAreaCode: String?
    let title: TitleResponse?
}

struct TitleResponse: Decodable {
    let id: String? // TODO: 제거
    let name: String
    let grade: String
    let type: String
}

struct Title: Decodable, Hashable {
    let id: String
    let name: String
    let type: String
    let condition: String
    let createdAt: String
}

extension Title {
    static func mock(
        id: String = UUID().uuidString,
        name: String = "칭호 이름",
        type: String = "STANDARD",
        condition: String = "기본 조건",
        createdAt: String = "2025-01-01T00:00:00"
    ) -> Title {
        Title(id: id, name: name, type: type, condition: condition, createdAt: createdAt)
    }
    
    static var mockStandard: Title {
        .mock(name: "일반 칭호", type: "STANDARD")
    }
    
    static var mockRare: Title {
        .mock(name: "희귀 칭호", type: "RARE")
    }

    static var mockLegend: Title {
        .mock(name: "전설 칭호", type: "LEGEND")
    }
}
