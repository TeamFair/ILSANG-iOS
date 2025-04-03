//
//  QuestNetwork.swift
//  ILSANG
//
//  Created by Kim Andrew on 7/2/24.
//

import Foundation
import Alamofire

final class QuestNetwork {
    
    private let questUrl: String = APIManager.makeURL(CustomerTarget(path: ""))
    
    func getDefaultQuest(page: Int, size: Int) async -> Result<ResponseWithPage<[Quest]>, Error> {
        let parameters: Parameters = ["page": page, "size": size]
        return await Network.requestData(url: questUrl+"uncompletedQuest", method: .get, parameters: parameters, withToken: true)
    } 
    
    func getRepeatQuest(status: RepeatType, page: Int, size: Int) async -> Result<ResponseWithPage<[Quest]>, Error> {
        let parameters: Parameters = ["status": status.toParam(), "page": page, "size": size]
        return await Network.requestData(url: questUrl+"uncompletedRepeatQuest", method: .get, parameters: parameters, withToken: true)
    }
    
    func getEventQuest(page: Int, size: Int) async -> Result<ResponseWithPage<[Quest]>, Error> {
        let parameters: Parameters = ["page": page, "size": size]
        return await Network.requestData(url: questUrl+"uncompletedEventQuest", method: .get, parameters: parameters, withToken: true)
    }
    
    func getCompletedQuest(page: Int, size: Int) async -> Result<ResponseWithPage<[Quest]>, Error> {
        let parameters: Parameters = ["page": page, "size": size]
        return await Network.requestData(url: questUrl+"completedQuest", method: .get, parameters: parameters, withToken: true)
    }
    
    /// 추천퀘스트 조회시 사용
    func getUncompletedTotalQuest(page: Int = 0, size: Int = 10) async -> Result<ResponseWithPage<[Quest]>, Error> {
        let parameters: Parameters = ["page": page, "size": size]
        return await Network.requestData(url: questUrl+"uncompletedTotalQuest", method: .get, parameters: parameters, withToken: true)
    }

    /// 인기퀘스트 조회시 사용
    func getPopularQuest(page: Int = 0, size: Int = 8) async -> Result<ResponseWithPage<[Quest]>, Error> {
        let parameters: Parameters = ["page": page, "size": size, "popularYn": true]
        return await Network.requestData(url: questUrl+"uncompletedTotalQuest", method: .get, parameters: parameters, withToken: true)
    }
    
    /// 큰 보상 퀘스트 조회시 사용
    func getLargeRewardQuestsByAllXpStats(page: Int = 0, size: Int = 3) async -> Result<[XpStat: [Quest]], Error> {
        var questsByStat: [XpStat: [Quest]] = [:]
        for xpStat in XpStat.allCases {
            do {
                let quests = try await getLargeRewardQuestsByXpStat(page: page, size: size, xpStat: xpStat).get().data
                questsByStat[xpStat, default: []] += quests
            } catch {
                return .failure(error)
            }
        }
        return .success(questsByStat)
    }
    
    func getLargeRewardQuestsByXpStat(page: Int, size: Int, xpStat: XpStat) async -> Result<ResponseWithPage<[Quest]>, Error> {
        let parameters: Parameters = ["page": page, "size": size, "rewardContent": xpStat.parameterText]
        return await Network.requestData(url: questUrl+"largeRewardQuest", method: .get, parameters: parameters, withToken: true)
    }
}
