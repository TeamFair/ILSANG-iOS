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
        return await Network.requestData(url: url+"/history/random", method: .get, parameters: parameters)
    }
    
    func getMissionHistories(missionId: Int, page: Int, size: Int) async -> Result<ResponseWithPage<[MissionHistoryResponse]>, Error> {
        let parameters: Parameters = ["missionId": missionId, "page": page, "size": size]
        return await Network.requestData(url: url+"/history/example", method: .get, parameters: parameters)
    }
    
    /// 수행한 퀘스트 이력(미션) 조회
    /// useId가 nil이면 현재 유저 정보
    func getMissionHistories(page: Int, size: Int, userId: String?, missionType: MissionType, orderRewardDesc: Bool?, orderCreatedAtDesc: Bool?) async -> Result<ResponseWithPage<[UserMissionHistoryResponse]>, Error> {
        var parameters: Parameters = [
            "page": page,
            "size": size,
            "missionType": missionType.parameterText
        ]
        if let userId {
            parameters["userId"] = userId
        }
        if let orderRewardDesc {
            parameters["orderRewardDesc"] = orderRewardDesc
        }
        if let orderCreatedAtDesc {
            parameters["orderCreatedAtDesc"] = orderCreatedAtDesc
        }
        return await Network.requestData(url: url+"/history", method: .get, parameters: parameters)
    }
    
    func getMissionHistoryDetail(missionHistoryId: Int) async -> Result<UserMissionHistoryDetailResponse, Error> {
        let parameters: Parameters = ["missionHistoryId": missionHistoryId]
        return await Network.requestData(url: url+"/history/detail", method: .get, parameters: parameters)
    }
    
    /// 신고하기
    func reportMissionHistory(missionHistoryId: Int, reason: String) async -> Result<ResultCodeResponse, Error> {
        let body: [String: Any] = ["reason": reason]
        guard let bodyData = body.convertToJsonData() else {
            return .failure(NetworkError.requestFailed("Fail to convert data"))
        }
        
        return await Network.requestData(url: url+"/history/\(missionHistoryId)", method: .put, body: bodyData)
    }
    
    func deleteMissionHistory(missionHistoryId: Int) async -> Result<ResponseWithEmpty, Error> {
        return await Network.requestData(url: url+"/history/\(missionHistoryId)", method: .delete)
    }
    
    func incrementMissionHistoryShareCount(missionHistoryId: Int) async -> Result<ResponseWithEmpty, Error> {
        return await Network.requestData(url: url+"/history/\(missionHistoryId)/share", method: .post)
    }
}
