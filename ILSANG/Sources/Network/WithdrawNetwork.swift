//
//  WithdrawNetwork.swift
//  ILSANG
//
//  Created by Kim Andrew on 6/22/24.
//

final class WithdrawNetwork {
    private let url = APIManager.makeURL(CustomerTarget(path: "withdraw"))
    
    func getWithdraw() async -> Result<ResponseWithoutData, Error> {
        await Network.requestData(url: url, method: .get, parameters: nil, withToken: true)
    }
}
