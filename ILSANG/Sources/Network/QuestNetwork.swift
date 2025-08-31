//
//  QuestNetwork.swift
//  ILSANG
//
//  Created by Kim Andrew on 7/2/24.
//

import Foundation
import Alamofire

final class QuestNetwork {
    
    private let questUrl: String = APIManager.makeURL(UserTarget(path: "quest", version: 1))
    
    /// 기본 퀘스트 조회
    func getDefaultQuests(commercialAreaCode: String, orderRewardDesc: Bool?, page: Int, size: Int) async -> Result<ResponseWithPage<[BaseQuestResponse]>, Error> {
        var parameters: Parameters = [
            "questType": "NORMAL",
            "completedYn": false,
            "commercialAreaCode": commercialAreaCode,
            "page": page,
            "size": size
        ]
        
        if let orderRewardDesc = orderRewardDesc {
            parameters["orderRewardDesc"] = orderRewardDesc
        }

        return await getQuests(parameters: parameters)
    }
    
    /// 반복 퀘스트 조회
    func getRepeatQuests(commercialAreaCode: String, repeatFrequency: RepeatType, orderRewardDesc: Bool?, page: Int, size: Int) async -> Result<ResponseWithPage<[BaseQuestResponse]>, Error> {
        var parameters: Parameters = [
            "questType": "REPEAT",
            "completedYn": false,
            "commercialAreaCode": commercialAreaCode,
            "repeatFrequency": repeatFrequency.toParam(),
            "page": page,
            "size": size
        ]
        
        if let orderRewardDesc = orderRewardDesc {
            parameters["orderRewardDesc"] = orderRewardDesc
        }

        return await getQuests(parameters: parameters)
    }
    
    /// 이벤트 퀘스트 조회
    func getEventQuests(commercialAreaCode: String, orderRewardDesc: Bool?, orderExpiredDesc: Bool?, page: Int, size: Int) async -> Result<ResponseWithPage<[BaseQuestResponse]>, Error> {
        var parameters: Parameters = [
            "questType": "EVENT",
            "completedYn": false,
            "commercialAreaCode": commercialAreaCode,
            "page": page,
            "size": size
        ]
        if let orderRewardDesc = orderRewardDesc {
            parameters["orderRewardDesc"] = orderRewardDesc
        }
        if let orderExpiredDesc = orderExpiredDesc {
            parameters["orderExpiredDesc"] = orderExpiredDesc
        }

        return await getQuests(parameters: parameters)
    }
    
    /// 완료 퀘스트 조회
    func getCompletedQuests(page: Int, size: Int) async -> Result<ResponseWithPage<[BaseQuestResponse]>, Error> {
        let parameters: Parameters = [
            "completedYn": true,
            "page": page,
            "size": size
        ]
        return await getQuests(parameters: parameters)
    }
    
    /// 퀘스트 유형별 조회
    private func getQuests(parameters: Parameters) async -> Result<ResponseWithPage<[BaseQuestResponse]>, Error> {
        return await Network.requestData(url: questUrl+"/search/type", method: .get, parameters: parameters)
    }
    
    /// 추천 퀘스트 조회
    func getRecommendQuests(commercialAreaCode: String, page: Int, size: Int) async -> Result<ResponseWithPage<[RecommendQuestResponse]>, Error> {
        let parameters: Parameters = ["commercialAreaCode": commercialAreaCode, "page": page, "size": size]
        return await Network.requestData(url: questUrl+"/search/recommend", method: .get, parameters: parameters)
    }
    
    /// 인기 퀘스트 조회
    func getPopularQuests(commercialAreaCode: String, page: Int, size: Int) async -> Result<ResponseWithPage<[PopularQuestResponse]>, Error> {
        let parameters: Parameters = ["commercialAreaCode": commercialAreaCode, "page": page, "size": size]
        return await Network.requestData(url: questUrl+"/search/popular", method: .get, parameters: parameters)
    }
    
    /// 큰 보상 퀘스트 조회
    func getLargeRewardQuests(commercialAreaCode: String, page: Int, size: Int) async -> Result<ResponseWithPage<[LargeRewardQuestResponse]>, Error> {
        let parameters: Parameters = ["commercialAreaCode": commercialAreaCode, "page": page, "size": size]
        return await Network.requestData(url: questUrl+"/search/reward", method: .get, parameters: parameters)
    }
    
    /// 퀘스트 상제 정보 조회
    func getQuestDetail(questId: Int) async -> Result<QuestDetailResponse, Error> {
        return await Network.requestData(url: questUrl+"/\(questId)", method: .get)
    }
}
