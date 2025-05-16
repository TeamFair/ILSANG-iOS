//
//  TitleHistory.swift
//  ILSANG
//
//  Created by Lee Jinhee on 5/13/25.
//

struct HonorHistory: Decodable {
    let titleHistory: TitleHistory?
    let title: Title
}

struct TitleHistory: Decodable {
    let id: String
    let createdAt: String
}

struct HistoryRank: Decodable {
    let customer: Customer
    let titleHistory: TitleHistory
}

struct Customer: Decodable {
    let status: String
    let nickname: String
    let xpPoint: Int
    let profileImage: String?
    let title: Title?
}


extension HonorHistory {
    func toDomain() -> HonorItem {
        return HonorItem(
            titleId: title.id,
            historyId: titleHistory?.id,
            isSelected: false,
            title: title.name,
            acquisitionCondition: title.condition,
            type: HonorGrade(rawValue: title.type) ?? .standard
        )
    }
}
