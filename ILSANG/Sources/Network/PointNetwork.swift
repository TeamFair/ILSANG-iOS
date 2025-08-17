//
//  PointNetwork.swift
//  ILSANG
//
//  Created by Kim Andrew on 6/21/24.
//

import Foundation
import Alamofire

final class PointNetwork {
    private let url = APIManager.makeURL(CustomerTarget(path: "xpStats"))
    
    func getPoints() async -> Result<Response<Point>,Error> {
        return await Network.requestData(url: url, method: .get, parameters: nil, withToken: true)
    }
    
    func getPoints(customerId: String) async -> Result<Response<Point>,Error> {
        return await Network.requestData(url: url, method: .get, parameters: ["customerId": customerId], withToken: true)
    }
}

// TODO: API 스펙 맞춰서 변경
struct Point: Decodable {
    let metro: Int
    let commercial: Int
    let contribution: Int
}
