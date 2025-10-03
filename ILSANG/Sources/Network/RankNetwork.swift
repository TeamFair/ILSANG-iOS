//
//  RankNetwork.swift
//  ILSANG
//
//  Created by Lee Jinhee on 1/17/25.
//

import Alamofire

final class RankNetwork {
    private let areaRankUrl = APIManager.makeURL(NoTarget(path: "rank", version: 1))
    private let userRankUrl = APIManager.makeURL(UserTarget(path: "rank", version: 1))
    
    // MARK: - 일상지역 / 일상존 랭킹
    /// 일상지역 종합 랭킹
    func getMetroAreaRank(seasonId: Int?) async -> Result<[MetroAreaRankResponse], Error> {
        var parameters: Parameters = [:]
        if let seasonId = seasonId {
            parameters["seasonId"] = seasonId
        }
        return await Network.requestData(url: areaRankUrl+"/area/metro", method: .get, parameters: parameters)
    }
    
    /// 일상존 종합 랭킹
    func getCommercialAreaRank(seasonId: Int?) async -> Result<[CommercialAreaRankResponse], Error> {
        var parameters: Parameters = [:]
        if let seasonId = seasonId {
            parameters["seasonId"] = seasonId
        }
        return await Network.requestData(url: areaRankUrl+"/area/commercial", method: .get, parameters: parameters)
    }
    
    // MARK: - 사용자 랭킹
    /// 포인트 합산 랭킹 (일상지역+일상존+기여도)
    func getTotalUserRank(commercialAreaCode: String) async -> Result<[UserRankResponse], Error> {
        let parameters: Parameters = ["commercialAreaCode": commercialAreaCode]
        return await Network.requestData(url: userRankUrl+"/total", method: .get, parameters: parameters)
    }
    
    /// 일상지역 사용자 전체 랭킹
    func getTopUserRank(metroAreaCode: String, seasonId: Int?) async -> Result<AreaUserRankResponse, Error> {
        var parameters: Parameters = ["metroAreaCode": metroAreaCode]
        if let seasonId = seasonId {
            parameters["seasonId"] = seasonId
        }
        return await Network.requestData(url: userRankUrl+"/metro", method: .get, parameters: parameters)
    }
    
    /// 일상존 사용자 전체 랭킹
    func getTopUserRank(commercialAreaCode: String, seasonId: Int?) async -> Result<AreaUserRankResponse, Error> {
        var parameters: Parameters = ["commercialAreaCode": commercialAreaCode]
        if let seasonId = seasonId {
            parameters["seasonId"] = seasonId
        }
        return await Network.requestData(url: userRankUrl+"/commercial", method: .get, parameters: parameters)
    }
    
    /// 기여도 종합 랭킹
    func getTopUserRank(seasonId: Int?) async -> Result<[UserRankResponse], Error> {
        var parameters: Parameters = [:]
        if let seasonId = seasonId {
            parameters["seasonId"] = seasonId
        }
        return await Network.requestData(url: userRankUrl+"/contribution", method: .get, parameters: parameters)
    }
}
