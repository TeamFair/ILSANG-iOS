//
//  UserTitle.swift
//  ILLSANG
//
//  Created by Lee Jinhee on 9/7/25.
//

import Foundation

struct UserTitle: Equatable {
    let titleHistoryId: Int?
    let name: String
    let grade: HonorGrade
    let createdAt: Date?
    
    static func == (lhs: UserTitle, rhs: UserTitle) -> Bool {
        lhs.titleHistoryId == rhs.titleHistoryId &&
        lhs.name == rhs.name &&
        lhs.grade == rhs.grade &&
        lhs.createdAt == rhs.createdAt
    }
}
