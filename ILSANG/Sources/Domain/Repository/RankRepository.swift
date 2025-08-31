//
//  RankRepository.swift
//  ILLSANG
//
//  Created by Lee Jinhee on 8/25/25.
//

protocol RankRepositoryInterface {
    func getMetroAreaRank(seasonId: Int?) async -> Result<[AreaRank], Error>
    func getCommercialAreaRank(seasonId: Int?) async -> Result<[AreaRank], Error>
    func getTotalUserRank(commercialAreaCode: String) async -> Result<[UserRank], Error>
    func getTopUserRank(metroAreaCode: String, seasonId: Int?) async -> Result<AreaUserRank, Error>
    func getTopUserRank(commercialAreaCode: String, seasonId: Int?) async -> Result<AreaUserRank, Error>
    func getTopUserRank(seasonId: Int?) async -> Result<[UserRank], Error>
}

final class RankRepository: RankRepositoryInterface {
    private let network: RankNetwork
    
    init(network: RankNetwork) {
        self.network = network
    }
    
    /// 일상지역 종합 랭킹
    func getMetroAreaRank(seasonId: Int?) async -> Result<[AreaRank], Error> {
        let res = await network.getMetroAreaRank(seasonId: seasonId)
        return ResponseMapper.mapArrayResponse(res)
    }
    
    /// 일상존 종합 랭킹
    func getCommercialAreaRank(seasonId: Int?) async -> Result<[AreaRank], Error> {
        let res = await network.getCommercialAreaRank(seasonId: seasonId)
        return ResponseMapper.mapArrayResponse(res)
    }
    
    /// 포인트 합산 랭킹 (일상지역+일상존+기여도)
    func getTotalUserRank(commercialAreaCode: String) async -> Result<[UserRank], Error> {
        let res = await network.getTotalUserRank(commercialAreaCode: commercialAreaCode)
        return ResponseMapper.mapArrayResponse(res)
    }
    
    /// 일상지역 사용자 전체 랭킹
    func getTopUserRank(metroAreaCode: String, seasonId: Int?) async -> Result<AreaUserRank, Error> {
        let res = await network.getTopUserRank(metroAreaCode: metroAreaCode, seasonId: seasonId)
        return ResponseMapper.mapResponse(res)
    }
    
    /// 일상존 사용자 전체 랭킹
    func getTopUserRank(commercialAreaCode: String, seasonId: Int?) async -> Result<AreaUserRank, Error> {
        let res = await network.getTopUserRank(commercialAreaCode: commercialAreaCode, seasonId: seasonId)
        return ResponseMapper.mapResponse(res)
    }
    
    /// 기여도 종합 랭킹
    func getTopUserRank(seasonId: Int?) async -> Result<[UserRank], Error> {
        let res = await network.getTopUserRank(seasonId: seasonId)
        return ResponseMapper.mapArrayResponse(res)
    }
}
