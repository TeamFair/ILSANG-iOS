//
//  Area.swift
//  ILSANG
//
//  Created by Lee Jinhee on 8/27/25.
//

struct MetroArea: Equatable {
    static func == (lhs: MetroArea, rhs: MetroArea) -> Bool {
        lhs.code == rhs.code
    }
    
    let code: String
    let areaName: String
    let commercialAreas: [CommercialArea]
}

struct CommercialArea: Equatable, Codable {
    let code: String
    let areaName: String
    let metroAreaCode: String
}
