//
//  LogoutNetwork.swift
//  ILSANG
//
//  Created by Kim Andrew on 6/22/24.
//

final class LogoutNetwork {
    private let url = APIManager.makeURL(CustomerTarget(path: "logout"))
    
    func getLogout() async -> Result<ResponseWithoutData, Error> {
        await Network.requestData(url: url, method: .get, parameters: nil, withToken: true)
    }
}
