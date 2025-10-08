//
//  SeasonResponse.swift
//  ILSANG
//
//  Created by Lee Jinhee on 8/13/25.
//

struct SeasonResponse: Decodable {
    let id: Int
    let seasonNumber: Int
    let startDate: String
    let endDate: String
}

extension SeasonResponse {
    static let mockData = SeasonResponse(
        id: 1,
        seasonNumber: 2,
        startDate: "2025.05.01",
        endDate: "2025.09.01",
    )
    
    static let mockDataList = [
        SeasonResponse(
            id: 1,
            seasonNumber: 3,
            startDate: "2025-07-15T15:10:36.969Z",
            endDate: "2025-08-16T15:10:36.969Z"),
        SeasonResponse(
            id: 2,
            seasonNumber: 4,
            startDate: "2025-09-16T01:10:36.969Z",
            endDate: "2025-09-20T15:10:36.969Z"
        )
    ]
}
