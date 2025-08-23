//
//  RankNetwork.swift
//  ILSANG
//
//  Created by Lee Jinhee on 1/17/25.
//

import Alamofire

// TODO: 지역시스템 > 랭킹 수정 필요
final class RankNetwork {
    private let openRankUrl = APIManager.makeURL(OpenTarget(path: "rank/top-users", version: 1))
    private let statRankUrl = APIManager.makeURL(UserTarget(path: "rank", version: 1))
    
    func getTopUserRank() async -> Result<Response<[TopRank]>, Error> {
        let parameters: Parameters = ["limit": 10]
        return await Network.requestData(url: openRankUrl, method: .get, parameters: parameters, withToken: false)
    }
    
    func getRankByStat(xpstat: String) async -> Result<Response<[StatRank]>, Error> {
        let parameters: Parameters = ["xpType":xpstat, "size": 20]
        return await Network.requestData(url: statRankUrl, method: .get, parameters: parameters, withToken: true)
    }
}
