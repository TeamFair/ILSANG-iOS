//
//  PointSummaryResponse.swift
//  ILSANG
//
//  Created by Lee Jinhee on 8/29/25.
//


struct PointSummaryResponse: Decodable {
    let topMetroAreaCode: String
    let topCommercialAreaCode: String
    let topContributionPoint: Int
}
