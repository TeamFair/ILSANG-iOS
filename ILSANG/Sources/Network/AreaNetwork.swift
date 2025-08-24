//
//  AreaNetwork.swift
//  ILLSANG
//
//  Created by Lee Jinhee on 8/24/25.
//


import Alamofire

final class AreaNetwork {
    private let url: String = APIManager.makeURL(NoTarget(path: "area/metro", version: 1))
    
    func getMetroArea() async -> Result<[MetroAreaResponse], Error> {
        return await Network.requestData(url: url, method: .get)
    }
}
