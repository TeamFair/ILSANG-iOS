//
//  HonorNetwork.swift
//  ILSANG
//
//  Created by Lee Jinhee on 5/13/25.
//

import Alamofire
import Foundation

protocol HonorNetworkProtocol {
    func getUnreadHonorHistory() async -> Result<Response<[HonorHistory]>, Error>
    func readHonorHistory(historyId: String) async -> Result<ResponseWithoutData, Error>
}

struct MockHonorNetwork: HonorNetworkProtocol {
    func getUnreadHonorHistory() async -> Result<Response<[HonorHistory]>, Error> {
        .success(Response(data: HonorHistory.mockList, errorStatus: "", errMessage: "", status: "", message: ""))
    }
    
    func readHonorHistory(historyId: String) async -> Result<ResponseWithoutData, Error> {
        .success(.init(data: [:]))
    }
}

final class HonorNetwork: HonorNetworkProtocol {
    private let url = APIManager.makeURL(UserTarget(path: "title/history", version: 1))
    
    func getHonorHistory() async -> Result<Response<[HonorHistory]>, Error> {
        return await Network.requestData(url: url, method: .get, parameters: nil, withToken: true)
    }
    
    func getUnreadHonorHistory() async -> Result<Response<[HonorHistory]>, Error> {
        return await Network.requestData(url: url+"/unread", method: .get, parameters: nil, withToken: true)
    }
    
    func readHonorHistory(historyId: String) async -> Result<ResponseWithoutData, Error> {
        return await Network.requestData(url: url+"/\(historyId)/read", method: .put, parameters: nil, withToken: true)
    }
    
    func getLegendRank(honorId: String) async -> Result<Response<[HistoryRank]>, Error> {
        let params = ["titleId": "\(honorId)"]
        return await Network.requestData(url: url+"/rank", method: .get, parameters: params, withToken: true)
    }
}
