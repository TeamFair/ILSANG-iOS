//
//  XPNetwork.swift
//  ILSANG
//
//  Created by Kim Andrew on 6/21/24.
//

import Foundation
import Alamofire

final class XPNetwork {
    private let historyUrl = APIManager.makeURL(CustomerTarget(path: "xpHistory"))
    private let statsUrl = APIManager.makeURL(CustomerTarget(path: "xpStats"))
    
    func getXpHistory(page: Int, size: Int) async -> Result<ResponseWithPage<[XpLog]>,Error> {
        let parameters: Parameters = ["page": page, "size": size]
        return await Network.requestData(url: historyUrl + "", method: .get, parameters: parameters, withToken: true)
    }
    
    func getXpStats() async -> Result<Response<XpStats>,Error> {
        return await Network.requestData(url: statsUrl, method: .get, parameters: nil, withToken: true)
    }
    
    func getXpStats(customerId: String) async -> Result<Response<XpStats>,Error> {
        return await Network.requestData(url: statsUrl, method: .get, parameters: ["customerId": customerId], withToken: true)
    }
}
