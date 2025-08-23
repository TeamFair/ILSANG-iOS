//
//  MissionResponse.swift
//  ILSANG
//
//  Created by Lee Jinhee on 8/21/25.
//


struct MissionResponse: Decodable {
    let id: Int
    let title: String
    let type: String // "PHOTO"
    let exampleImageIds: [String]?
}
