//
//  FavoriteNetwork.swift
//  ILSANG
//
//  Created by Lee Jinhee on 4/7/25.
//

final class FavoriteNetwork {
    private let url: String = APIManager.makeURL(UserTarget(path: "quest", version: 1))
        
    func post(questId: Int) async -> Bool {
        let body = ["questId": "\(questId)"]
        let bodyData = body.convertToJsonData()
        let res: Result<ResponseWithEmpty, Error> = await Network.requestData(url: url+"/favorite", method: .post, body: bodyData)
        switch res {
        case .success:
            return true
        case .failure:
            return false
        }
    }
    
    func delete(questId: Int) async -> Bool {
        let body = ["questId": "\(questId)"]
        let bodyData = body.convertToJsonData()
        let res: Result<ResponseWithEmpty, Error> = await Network.requestData(url: url+"/favorite", method: .delete, body: bodyData)
        switch res {
        case .success:
            return true
        case .failure:
            return false
        }
    }
}
