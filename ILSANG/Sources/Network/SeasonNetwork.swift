//
//  SeasonNetwork.swift
//  ILLSANG
//
//  Created by Lee Jinhee on 8/13/25.
//

import Foundation

protocol SeasonNetworkProtocol {
    func getSeasons() async -> Result<Response<[Season]>, Error>
}

struct MockSeasonNetwork: SeasonNetworkProtocol {
    func getSeasons() async -> Result<Response<[Season]>, Error> {
        .success(Response(data: Season.mockDataList, errorStatus: "", errMessage: "", status: "", message: ""))
    }
}

final class SeasonNetwork: SeasonNetworkProtocol {
    private let url = APIManager.makeURL(NoTarget(path: "season", version: 1))
    
    func getSeasons() async -> Result<Response<[Season]>, Error> {
        return await Network.requestData(url: url, method: .get, parameters: nil, withToken: true)
    }
}
