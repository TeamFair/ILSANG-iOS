//
//  Title.swift
//  ILSANG
//
//  Created by Lee Jinhee on 9/7/25.
//


import Foundation

struct TitleResponse: Decodable, Hashable {
    let id: String
    let name: String
    let type: String // METRO
    let grade: String //STANDARD
    let condition: String
}

extension TitleResponse {
    static func mock(
        id: String = UUID().uuidString,
        name: String = "칭호 이름",
        type: String = "METRO",
        grade: String = "STANDARD",
        condition: String = "기본 조건"
    ) -> TitleResponse {
        TitleResponse(id: id, name: name, type: type, grade: grade, condition: condition)
    }
    
    static let mockStandard: TitleResponse = .mock(name: "일반 칭호", grade: "STANDARD")
    static let mockRare: TitleResponse = .mock(name: "희귀 칭호", grade: "RARE")
    static let mockLegend: TitleResponse = .mock(name: "전설 칭호", grade: "LEGEND")
}
