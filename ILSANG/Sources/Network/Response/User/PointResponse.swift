//
//  PointResponse.swift
//  ILSANG
//
//  Created by Lee Jinhee on 8/29/25.
//


struct PointResponse: Decodable {
    let completedQuestCount: Int
    let metroAreaPoint: Int
    let commercialAreaPoint: Int
    let contributionPoint: Int
}
