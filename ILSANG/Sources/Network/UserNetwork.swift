//
//  UserNetwork.swift
//  ILSANG
//
//  Created by Kim Andrew on 6/21/24.
//

import Foundation
import Alamofire

final class UserNetwork {
    private let url = APIManager.makeURL(CustomerTarget(path: "user"))
    
    func getUser() async -> Result<Response<User>, Error> {
        return await Network.requestData(url: url, method: .get, parameters: nil, withToken: true)
    }
    
    func getUser(customerId: String) async -> Result<Response<User>, Error> {
        return await Network.requestData(url: url, method: .get, parameters: ["customerId": customerId], withToken: true)
    }
    
    func putUser(nickname: String) async -> Bool {
        let body = ["nickname": nickname]
        let bodyData = body.convertToJsonData()
        let res: Result<ResponseWithoutData, Error> = await Network.requestData(url: url, method: .put, parameters: nil, body: bodyData, withToken: true)
        
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
        let res: Result<ResponseWithoutData, Error> = await Network.requestData(url: url+"/image", method: .put, parameters: nil, body: bodyData, withToken: true)
        
        switch res {
        case.success:
            return true
        case.failure:
            return false
        }
    }
    
    /// 서버에서 프로필 이미지 연결 해제 & 이미지 삭제 처리
    func deleteUserImage() async -> Bool {
        let res: Result<ResponseWithoutData, Error> = await Network.requestData(url: url+"/image", method: .delete, parameters: nil, withToken: true)
        
        switch res {
        case.success:
            return true
        case.failure:
            return false
        }
    }
}
