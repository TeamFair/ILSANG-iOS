//
//  CouponNetwork.swift
//  ILSANG
//
//  Created by Lee Jinhee on 9/5/25.
//

import Alamofire

final class CouponNetwork {
    private let url = APIManager.makeURL(NoTarget(path: "user/coupon", version: 1))
    
    func getCoupons(page: Int, size: Int) async -> Result<[UserCouponResponse], Error> {
        let parameters: Parameters = ["page": page, "size": size]
        return await Network.requestData(url: url, method: .get, parameters: parameters)
    }
    
    func verifyPassword(id: Int, password: String) async -> Result<VerifyPasswordResponse, Error> {
        let body = ["password": password]
        let bodyData = body.convertToJsonData()
        return await Network.requestData(url: url+"/\(id)/verify-password", method: .post, body: bodyData)
    }
    
    func useCoupon(id: Int) async -> Result<UserCouponResponse, Error> {
        let body = ["couponUseYn": true]
        let bodyData = body.convertToJsonData()
        return await Network.requestData(url: url+"/\(id)", method: .put, body: bodyData)
    }
}
