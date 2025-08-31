//
//  Season.swift
//  ILSANG
//
//  Created by Lee Jinhee on 8/13/25.
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
   
    static let mockData = Season(
        id: 1,
        seasonNumber: 2,
        startDate: "2025.05.01",
        endDate: "2025.09.01",
    )
    
    static let mockDataList = [
        Season(
            id: 1,
            seasonNumber: 3,
            startDate: "2025-07-15T15:10:36.969Z",
            endDate: "2025-08-16T15:10:36.969Z"),
        Season(
            id: 2,
            seasonNumber: 4,
            startDate: "2025-09-16T01:10:36.969Z",
            endDate: "2025-09-20T15:10:36.969Z"
        )
    ]
}
extension ISO8601DateFormatter {
    static func dateOnlyString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul") // 한국 기준
        return formatter.string(from: date)
    }
}
