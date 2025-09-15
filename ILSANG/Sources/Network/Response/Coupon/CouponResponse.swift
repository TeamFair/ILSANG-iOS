//
//  CouponResponse.swift
//  ILLSANG
//
//  Created by Lee Jinhee on 9/5/25.
//

import Foundation

struct CouponResponse: Decodable {
    let id: Int
    let name: String
    let imageId: String?
    let storeName: String?
    let description: String?
    let validFrom: String?
    let validTo: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case couponId
        case name
        case imageId
        case storeName
        case description
        case validFrom
        case validTo
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // couponId가 없으면 id를 사용
        self.id = try container.decodeIfPresent(Int.self, forKey: .couponId)
            ?? container.decode(Int.self, forKey: .id)
        
        self.name = try container.decode(String.self, forKey: .name)
        self.imageId = try container.decodeIfPresent(String.self, forKey: .imageId)
        self.storeName = try container.decodeIfPresent(String.self, forKey: .storeName)
        self.description = try container.decodeIfPresent(String.self, forKey: .description)
        self.validFrom = try container.decodeIfPresent(String.self, forKey: .validFrom)
        self.validTo = try container.decodeIfPresent(String.self, forKey: .validTo)
    }
}
