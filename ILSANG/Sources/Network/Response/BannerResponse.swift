//
//  BannerResponse.swift
//  ILSANG
//
//  Created by Lee Jinhee on 8/26/25.
//


struct BannerResponse: Decodable {
    let id: Int
    let title: String
    let navigationTitle: String
    let bannerImageId: String
    let description: String
}
