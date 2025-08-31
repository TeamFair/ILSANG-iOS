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
    
    func getMissionHistories(page: Int, size: Int, userId: String?) async -> Result<(data: [UserMissionHistory], total: Int), Error> {
        let res = await network.getMissionHistories(page: page, size: size, userId: userId)
        switch res {
        case .success(let response):
            let domainModels = response.content.map { $0.toDomain() }
            return .success((domainModels, response.totalElements))
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func deleteMissionHistory(missionHistoryId: Int) async -> Bool {
        let res = await network.deleteMissionHistory(missionHistoryId: missionHistoryId)
        switch res {
        case .success:
            return true
        case .failure:
            return false
        }
    }
    
    // 신고하기
    func putMissionHistory(missionHistoryId: Int) async -> Result<Void, Error> {
        let res = await network.putMissionHistory(missionHistoryId: missionHistoryId)
        switch res {
        case .success:
            return .success(Void())
        case .failure(let error):
            return .failure(error)
        }
    }
}
