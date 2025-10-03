//
//  TitleRepository.swift
//  ILLSANG
//
//  Created by Lee Jinhee on 9/7/25.
//

import Foundation

protocol TitleRepositoryInterface {
    func getTitles() async -> Result<[Title], Error>
    func getTitleHistories() async -> Result<[UserTitle], Error>
    func getUnreadTitleHistories() async -> Result<[UserTitle], Error>
    func readTitleHistory(historyId: Int) async -> Result<Void, Error>
    func getSeasonTitles(type: PointType) async -> Result<[Title], Error>
    func getLegendRank(titleId: String, page: Int, size: Int) async ->  Result<(data: [LegendRank], total: Int), Error>
}

final class TitleRepository: TitleRepositoryInterface {
    private let network: TitleNetworkInterface
    
    init(network: TitleNetworkInterface) {
        self.network = network
    }
    
    func getTitles() async -> Result<[Title], Error> {
        let res = await network.getTitles()
        return ResponseMapper.mapArrayResponse(res)
    }
    
    func getTitleHistories() async -> Result<[UserTitle], Error> {
        let res = await network.getTitleHistories()
        return ResponseMapper.mapArrayResponse(res)
    }
    
    func getUnreadTitleHistories() async -> Result<[UserTitle], Error> {
        let res = await network.getUnreadTitleHistories()
        return ResponseMapper.mapArrayResponse(res)
    }
    
    func readTitleHistory(historyId: Int) async -> Result<Void, Error> {
        let result = await network.readTitleHistory(historyId: historyId)
        switch result {
        case .success:
            return .success(Void())
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func getSeasonTitles(type: PointType) async -> Result<[Title], Error> {
        let res = await network.getSeasonTitles(type: type)
        return ResponseMapper.mapArrayResponse(res)
    }
    
    func getLegendRank(titleId: String, page: Int, size: Int) async ->  Result<(data: [LegendRank], total: Int), Error> {
        let result = await network.getLegendRank(titleId: titleId, page: page, size: size)
        switch result {
        case .success(let response):
            let domainModels = response.content.map { $0.toDomain() }
            return .success((domainModels, response.totalElements))
        case .failure(let error):
            return .failure(error)
        }
    }
}
