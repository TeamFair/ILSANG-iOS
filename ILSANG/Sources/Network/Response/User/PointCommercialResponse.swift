//
//  PointCommercialResponse.swift
//  ILSANG
//
//  Created by Lee Jinhee on 8/29/25.
//


struct PointCommercialResponse: Decodable, Equatable {
    static func == (lhs: PointCommercialResponse, rhs: PointCommercialResponse) -> Bool {
        lhs.totalOwnerContributions == rhs.totalOwnerContributions
    }
    
    let topCommercialArea: TopCommercialAreaReponse?
    let totalOwnerContributions: [TotalOwnerContributionResponse]
}

struct TopCommercialAreaReponse: Decodable {
    let commercialAreaCode: String
    let point: Int
    let ownerContributionPercent: Double
}

struct TotalOwnerContributionResponse: Decodable, Equatable {
    let commercialAreaCode: String
    let point: Int
}
