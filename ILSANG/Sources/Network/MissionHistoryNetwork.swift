//
//  MissionHistoryNetwork.swift
//  ILLSANG
//
//  Created by Lee Jinhee on 8/19/25.
//


import Alamofire

final class MissionHistoryNetwork {
    private let url: String = APIManager.makeURL(UserTarget(path: "mission", version: 1))
    
    func getRandomMissionHistories(page: Int, size: Int = 10) async -> Result<ResponseWithPage<[MissionHistoryResponse]>, Error> {
        let parameters: Parameters = ["page": page, "size": size]
        return await Network.requestData(url: url+"history/random", method: .get, parameters: parameters, withToken: true)
    }
    
    func patchMissionHistory(missionHistoryId: Int) async -> Result<ResponseWithEmpty, Error> {
        let parameters: Parameters = ["missionHistoryId": "\(missionHistoryId)", "status": "REPORTED"]
        return await Network.requestData(url: url+"history/status", method: .patch, parameters: parameters, withToken: true)
    }
}
