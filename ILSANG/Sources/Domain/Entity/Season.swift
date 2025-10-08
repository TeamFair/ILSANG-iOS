//
//  Season.swift
//  ILSANG
//
//  Created by Lee Jinhee on 10/4/25.
//

import Foundation

struct Season: Decodable, Equatable {
    let id: Int
    let seasonNumber: Int
    let startDate: String
    let endDate: String
    
    func containsToday() -> Bool {
        let todayString = ISO8601DateFormatter.dateOnlyString(from: Date())
        
        let startDateOnly = String(startDate.prefix(10)) // "2025-08-13"
        let endDateOnly = String(endDate.prefix(10))
        
        return todayString >= startDateOnly && todayString <= endDateOnly
    }
}

extension Season {
    static let mockData: Season = Season(
        id: 1,
        seasonNumber: 1,
        startDate: "2025-08-13",
        endDate: "2025-08-13"
    )
}
