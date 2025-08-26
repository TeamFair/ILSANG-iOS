//
//  BannerNetwork.swift
//  ILSANG
//
//  Created by Lee Jinhee on 1/23/25.
//

import Foundation

final class BannerNetwork {
    private let url = APIManager.makeURL(UserTarget(path: "banner", version: 1))
    
    func getMainBanners() async -> Result<[BannerResponse], Error> {
        return await Network.requestData(url: url, method: .get)
    }
}
