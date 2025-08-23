//
//  MissionHistoryRepository.swift
//  ILLSANG
//
//  Created by Lee Jinhee on 8/18/25.
//

import Foundation

final class MissionHistoryRepository {
    private let network: MissionHistoryNetwork
    
    init(network: MissionHistoryNetwork) {
        self.network = network
    }
    
    func getRandomMissionHistories(page: Int, size: Int) async -> Result<(data: [MissionHistory], total: Int), Error> {
        let res = await network.getRandomMissionHistories(page: page, size: size)
        switch res {
        case .success(let response):
            let domainModels = response.content.map { $0.toDomain() }
            return .success((domainModels, response.totalElements))
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func patchMissionHistory(missionHistoryId: Int) async -> Result<Void, Error> {
        let res = await network.patchMissionHistory(missionHistoryId: missionHistoryId)
        switch res {
        case .success:
            return .success(Void())
        case .failure(let error):
            return .failure(error)
        }
    }
}
