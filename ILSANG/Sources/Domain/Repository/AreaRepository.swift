//
//  AreaRepositoryInterface.swift
//  ILSANG
//
//  Created by Lee Jinhee on 8/26/25.
//

import Foundation

protocol AreaRepositoryInterface {
    func getMetroAreas(forceRefresh: Bool) async -> Result<[MetroArea], Error>
}

final class AreaRepository: AreaRepositoryInterface {
    private let network: AreaNetwork
    private var memoryCache: [MetroArea]?

    init(network: AreaNetwork) {
        self.network = network
    }

    func getMetroAreas(forceRefresh: Bool = false) async -> Result<[MetroArea], Error> {
        // 메모리 캐시
        if let cached = memoryCache, !forceRefresh {
            return .success(cached)
        }

        // TODO: 디스크 캐시

        // 네트워크
        let result = await network.getMetroAreas()
        switch result {
        case .success(let areas):
            let metroAreas = areas.map { $0.toDomain() }
            memoryCache = metroAreas
            return .success(metroAreas)
        case .failure(let error):
            return .failure(error)
        }
    }
}
