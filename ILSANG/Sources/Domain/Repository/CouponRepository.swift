//
//  CouponRepository.swift
//  ILLSANG
//
//  Created by Lee Jinhee on 9/5/25.
//

import Foundation

protocol CouponRepositoryInterface {
    func getCoupons(page: Int, size: Int) async -> Result<ResponseWithPage<[UserCoupon]>, Error>
    func verifyPassword(id: Int, password: String) async -> Result<Bool, Error>
    func useCoupon(id: Int) async -> Result<UserCoupon, Error>
}

final class CouponRepository: CouponRepositoryInterface {
    private let network: CouponNetwork
    
    init(network: CouponNetwork) {
        self.network = network
    }
    
    func getCoupons(page: Int, size: Int) async -> Result<ResponseWithPage<[UserCoupon]>, Error> {
        let res = await network.getCoupons(page: page, size: size)
        return ResponseMapper.mapPagedResponse(res)
    }
    
    func verifyPassword(id: Int, password: String) async -> Result<Bool, Error> {
        let result = await network.verifyPassword(id: id, password: password)
        switch result {
        case .success(let response):
            return .success(response.success)
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func useCoupon(id: Int) async -> Result<UserCoupon, Error> {
        let result = await network.useCoupon(id: id)
        return ResponseMapper.mapResponse(result)
    }
}
