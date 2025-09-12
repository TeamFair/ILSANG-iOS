//
//  UserRepository.swift
//  ILLSANG
//
//  Created by Lee Jinhee on 8/29/25.
//

import Foundation

protocol UserRepositoryInterface {
    func getUser() async -> Result<User, Error>
    func getUser(userId: String) async -> Result<User, Error>
    func putUser(nickname: String) async -> Bool
    func putUserImage(imageId: String) async -> Bool
    func putHonor(historyId: Int?) async -> Bool
    func putAreaZone(commercialAreaCode: String) async -> Bool
    func getUserPoint(userId: String?, seasonId: Int?) async -> Result<PointResponse, Error>
    func getUserPointSummary(seasonId: Int) async -> Result<PointSummary, Error>
    func getUserPointCommercial(userId: String?) async -> Result<PointCommercial, Error>
    func deleteUserImage() async -> Bool
}

final class UserRepository: UserRepositoryInterface {
    private let network: UserNetwork
    
    init(network: UserNetwork) {
        self.network = network
    }
    
    func getUser() async -> Result<User, Error> {
        let res = await network.getUser()
        return ResponseMapper.mapResponse(res)
    }
    
    func getUser(userId: String) async -> Result<User, Error> {
        let res = await network.getUser(userId: userId)
        return ResponseMapper.mapResponse(res)
    }
    
    func putUser(nickname: String) async -> Bool {
        return await network.putUser(nickname: nickname)
    }
    
    func putUserImage(imageId: String) async -> Bool {
        return await network.putUserImage(imageId: imageId)
    }
    
    func putHonor(historyId: Int?) async -> Bool {
        return await network.putHonor(historyId: historyId)
    }
    
    func putAreaZone(commercialAreaCode: String) async -> Bool {
        return await network.putAreaZone(commercialAreaCode: commercialAreaCode)
    }
    
    func deleteUserImage() async -> Bool {
        return await network.deleteUserImage()
    }
    
    func getUserPoint(userId: String?, seasonId: Int?) async -> Result<PointResponse, Error> {
        let res = await network.getUserPoint(userId: userId, seasonId: seasonId)
        switch res {
        case .success(let user):
            return .success(user)
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func getUserPointSummary(seasonId: Int) async -> Result<PointSummary, Error> {
        let res = await network.getUserPointSummary(seasonId: seasonId)
        return ResponseMapper.mapResponse(res)
    }
    
    func getUserPointCommercial(userId: String?) async -> Result<PointCommercial, Error> {
        let res = await network.getUserPointCommercial(userId: userId)
        return ResponseMapper.mapResponse(res)
    }
}
