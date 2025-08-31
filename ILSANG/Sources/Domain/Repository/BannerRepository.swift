//
//  BannerRepository.swift
//  ILLSANG
//
//  Created by Lee Jinhee on 8/26/25.
//

import Foundation

protocol BannerRepositoryInterface {
    func getBanner() async -> Result<[Banner], Error>
}

final class BannerRepository: BannerRepositoryInterface {
    private let network: BannerNetwork
    
    init(network: BannerNetwork) {
        self.network = network
    }
    
    func getBanner() async -> Result<[Banner], Error> {
        let res = await network.getMainBanners()
        return ResponseMapper.mapArrayResponse(res)
    }
}
