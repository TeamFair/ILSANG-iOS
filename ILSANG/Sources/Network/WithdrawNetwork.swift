//
//  WithdrawNetwork.swift
//  ILSANG
//
//  Created by Kim Andrew on 6/22/24.
//

final class WithdrawNetwork {
    private let url = APIManager.makeURL(NoTarget(path: "withdraw", version: 1))
    
    func getWithdraw() async -> Result<ResponseWithoutData, Error> {
        await Network.requestData(url: url, method: .get, parameters: nil, withToken: true)
    }
}
