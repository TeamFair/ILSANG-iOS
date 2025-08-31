//
//  Image.swift
//  ILSANG
//
//  Created by Lee Jinhee on 6/27/24.
//

struct ImageEntity: Codable {
    var imageId: String
    
    enum CodingKeys: String, CodingKey {
        case imageId = "id"
    }
}
