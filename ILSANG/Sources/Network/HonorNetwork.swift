//
//  HonorNetwork.swift
//  ILSANG
//
//  Created by Lee Jinhee on 5/13/25.
//

import Alamofire
import Foundation

final class HonorNetwork {
    private let url = APIManager.makeURL(CustomerTarget(path: "title/history"))
    
    func getHonorHistory() async -> Result<Response<[HonorHistory]>, Error> {
        return await Network.requestData(url: url, method: .get, parameters: nil, withToken: true)
    }
    
    func getLegendRank(honorId: String) async -> Result<Response<[HistoryRank]>, Error> {
        let params = ["titleId": "\(honorId)"]
        return await Network.requestData(url: url+"/rank", method: .get, parameters: params, withToken: true)
    }
}
