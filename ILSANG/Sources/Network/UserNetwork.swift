//
//  UserNetwork.swift
//  ILSANG
//
//  Created by Kim Andrew on 6/21/24.
//

import Foundation
import Alamofire

final class UserNetwork {
    private let url = APIManager.makeURL(NoTarget(path: "user", version: 1))
    
    func getUser() async -> Result<UserResponse, Error> {
        return await Network.requestData(url: url, method: .get)
    }
    
    func getUser(userId id: String) async -> Result<UserResponse, Error> {
        return await Network.requestData(url: url, method: .get, parameters: ["id": id])
    }
    
    func putUser(nickname: String) async -> Bool {
        let body = ["nickName": nickname]
        let bodyData = body.convertToJsonData()
        let res: Result<ResponseWithoutData, Error> = await Network.requestData(url: url+"/profile/nickname", method: .put, body: bodyData)
        
        switch res {
        case.success:
            return true
        case.failure:
            return false
        }
    }
    
    func putUserImage(imageId: String) async -> Bool {
        let body = ["imageId": imageId]
        let bodyData = body.convertToJsonData()
        let res: Result<ResponseWithoutData, Error> = await Network.requestData(url: url+"/profile/image", method: .put, parameters: nil, body: bodyData, withToken: true)
        
        switch res {
        case.success:
            return true
        case.failure:
            return false
        }
    }
    
    /// titleHistoryId값을 null이나 빈값으로 요청하면 칭호 미사용
    func putHonor(historyId: Int?) async -> Bool {
        var body: [String: Any] = [:]
        if let historyId = historyId {
            body["titleHistoryId"] = historyId
        }
        let bodyData = body.convertToJsonData()
        let res: Result<ResponseWithoutData, Error> = await Network.requestData(url: url+"/profile/title", method: .put, body: bodyData)
        switch res {
        case.success:
            return true
        case.failure:
            return false
        }
    }
    
    func putAreaZone(commercialAreaCode: String) async -> Bool {
        let body = ["commercialAreaCode": commercialAreaCode]
        let bodyData = body.convertToJsonData()
        let res: Result<ResponseWithoutData, Error> = await Network.requestData(url: url+"/profile/area-zone", method: .put, body: bodyData)
        switch res {
        case.success:
            return true
        case.failure:
            return false
        }
    }
    
    func getUserPoint(userId: String?, seasonId: Int?) async -> Result<PointResponse, Error> {
        var parameters: Parameters = [:]
        if let userId {
            parameters["userId"] = userId
        }
        if let seasonId {
            parameters["seasonId"] = seasonId
        }
        return await Network.requestData(url: url+"/point", method: .get, parameters: parameters)
    }
    
    // TODO: nil 반환할 수 있는지 확인
    func getUserPointSummary(seasonId: Int) async -> Result<PointSummaryResponse, Error> {
        let parameters = ["seasonId": "\(seasonId)"]
        return await Network.requestData(url: url+"/point/summary", method: .get, parameters: parameters)
    }
    
    func getUserPointCommercial(userId: String?) async -> Result<PointCommercialResponse, Error> {
        var parameters: Parameters = [:]
        if let userId {
            parameters["userId"] = userId
        }
        return await Network.requestData(url: url+"/point/commercial", method: .get, parameters: parameters)
    }
    
    /// 서버에서 프로필 이미지 연결 해제 & 이미지 삭제 처리
    func deleteUserImage() async -> Bool {
        let body = ["imageId": nil] as [String : Any?]
        let bodyData = body.convertToJsonData()
        let res: Result<ResponseWithoutData, Error> = await Network.requestData(url: url+"/profile/image", method: .put, body: bodyData)
        switch res {
        case.success:
            return true
        case.failure:
            return false
        }
    }
}
