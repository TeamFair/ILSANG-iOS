//
//  FavoriteNetwork.swift
//  ILSANG
//
//  Created by Lee Jinhee on 4/7/25.
//

import Foundation

final class FavoriteNetwork {
    private let url: String
    
    init(url: String = APIManager.makeURL(CustomerTarget(path: "quest"))) {
        self.url = url
    }
        
    func post(questId: String) async -> Bool {
        let res: Result<ResponseWithoutData, Error> = await Network.requestData(url: url+"/\(questId)/favorite", method: .post, parameters: nil, body: nil, withToken: true)
        switch res {
        case .success:
            return true
        case .failure:
            return false
        }
    }
    
    func delete(questId: String) async -> Bool {
        let res: Result<ResponseWithoutData, Error> = await Network.requestData(url: url+"/\(questId)/favorite", method: .delete, parameters: nil, withToken: true)
        switch res {
        case .success:
            return true
        case .failure:
            return false
        }
    }
}
