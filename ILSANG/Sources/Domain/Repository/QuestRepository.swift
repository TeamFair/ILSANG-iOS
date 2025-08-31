//
//  QuestRepository.swift
//  ILSANG
//
//  Created by Lee Jinhee on 8/21/25.
//

import Foundation

protocol QuestRepositoryInterface {
    func getDefaultQuests(commercialAreaCode: String, orderRewardDesc: Bool?, page: Int, size: Int) async -> Result<ResponseWithPage<[Quest]>, Error>
    func getRepeatQuests(commercialAreaCode: String, repeatFrequency: RepeatType, orderRewardDesc: Bool?, page: Int, size: Int) async -> Result<ResponseWithPage<[Quest]>, Error>
    func getEventQuests(commercialAreaCode: String, orderRewardDesc: Bool?, orderExpiredDesc: Bool?, page: Int, size: Int) async -> Result<ResponseWithPage<[Quest]>, Error>
    func getCompletedQuests(page: Int, size: Int) async -> Result<ResponseWithPage<[Quest]>, Error>
    func getRecommendQuests(commercialAreaCode: String, page: Int, size: Int) async -> Result<ResponseWithPage<[Quest]>, Error>
    func getPopularQuests(commercialAreaCode: String, page: Int, size: Int) async -> Result<ResponseWithPage<[Quest]>, Error>
    func getLargeRewardQuests(commercialAreaCode: String, page: Int, size: Int) async -> Result<ResponseWithPage<[Quest]>, Error>
    func getQuestDetail(questId: Int) async -> Result<Quest, Error>
}

final class QuestRepository: QuestRepositoryInterface {
    private let network: QuestNetwork
    
    init(network: QuestNetwork) {
        self.network = network
    }
    
    func getDefaultQuests(commercialAreaCode: String, orderRewardDesc: Bool?, page: Int, size: Int) async -> Result<ResponseWithPage<[Quest]>, Error> {
        let res = await network.getDefaultQuests(commercialAreaCode: commercialAreaCode, orderRewardDesc: orderRewardDesc, page: page, size: size)
        return ResponseMapper.mapPagedResponse(res)
    }
    
    func getRepeatQuests(commercialAreaCode: String, repeatFrequency: RepeatType, orderRewardDesc: Bool?, page: Int, size: Int) async -> Result<ResponseWithPage<[Quest]>, Error> {
        let res = await network.getRepeatQuests(commercialAreaCode: commercialAreaCode, repeatFrequency: repeatFrequency, orderRewardDesc: orderRewardDesc, page: page, size: size)
        return ResponseMapper.mapPagedResponse(res)
    }
    
    func getEventQuests(commercialAreaCode: String, orderRewardDesc: Bool?, orderExpiredDesc: Bool?, page: Int, size: Int) async -> Result<ResponseWithPage<[Quest]>, Error> {
        let res = await network.getEventQuests(commercialAreaCode: commercialAreaCode, orderRewardDesc: orderRewardDesc, orderExpiredDesc: orderExpiredDesc, page: page, size: size)
        return ResponseMapper.mapPagedResponse(res)
    }
    
    func getCompletedQuests(page: Int, size: Int) async -> Result<ResponseWithPage<[Quest]>, Error> {
        let res = await network.getCompletedQuests(page: page, size: size)
        return ResponseMapper.mapPagedResponse(res)
    }
    
    func getRecommendQuests(commercialAreaCode: String, page: Int = 0, size: Int) async -> Result<ResponseWithPage<[Quest]>, Error> {
        let res = await network.getRecommendQuests(commercialAreaCode: commercialAreaCode, page: page, size: size)
        return ResponseMapper.mapPagedResponse(res)
    }
    
    func getPopularQuests(commercialAreaCode: String, page: Int = 0, size: Int) async -> Result<ResponseWithPage<[Quest]>, Error> {
        let res = await network.getPopularQuests(commercialAreaCode: commercialAreaCode, page: page, size: size)
        return ResponseMapper.mapPagedResponse(res)
    }
    
    func getLargeRewardQuests(commercialAreaCode: String, page: Int = 0, size: Int = 3) async -> Result<ResponseWithPage<[Quest]>, Error> {
        let res = await network.getLargeRewardQuests(commercialAreaCode: commercialAreaCode, page: page, size: size)
        return ResponseMapper.mapPagedResponse(res)
    }
    
    func getQuestDetail(questId: Int) async -> Result<Quest, Error> {
        let res = await network.getQuestDetail(questId: questId)
        return ResponseMapper.mapResponse(res)
    }
}

final class MockQuestRepository: QuestRepositoryInterface {
    private let mockQuests: [Quest] = [
        Quest(
            id: 0,
            title: "일반 퀘스트",
            writer: "일상",
            questType: .normal,
            repeatFrequency: nil,
            rewards: [Reward(point: 10, pointType: .commercial), Reward(point: 10, pointType: .metro), Reward(point: 10, pointType: .contribution)],
            missions: [Mission(id: 100, type: .photo, exampleImageIds: ["IMQU/2025082308223895"])],
            expireDate: .now,
            imageId: "IMQU/2025082308223895",
            mainImageId: "IMQU/2025082308223895",
            userRank: nil,
            favoriteYn: false
        )
    ]
    private let mockRepeatQuests: [Quest] = [
        Quest(
            id: 1,
            title: "반복 일간 퀘스트",
            writer: "일상",
            questType: .repeat,
            repeatFrequency: .daily,
            rewards: [Reward(point: 10, pointType: .commercial), Reward(point: 10, pointType: .metro), Reward(point: 10, pointType: .contribution)],
            missions: [Mission(id: 100, type: .photo, exampleImageIds: ["IMQU/2025082308223895"])],
            expireDate: .now,
            imageId: "IMQU/2025082308223895",
            mainImageId: "IMQU/2025082308223895",
            userRank: nil,
            favoriteYn: false
        )
    ]
    
    private let mockEventQuests: [Quest] = [
        Quest(
            id: 2,
            title: "이벤트 퀘스트",
            writer: "일상",
            questType: .event,
            repeatFrequency: nil,
            rewards: [Reward(point: 10, pointType: .commercial), Reward(point: 10, pointType: .metro), Reward(point: 10, pointType: .contribution)],
            missions: [Mission(id: 100, type: .photo, exampleImageIds: [])],
            expireDate: .now,
            imageId: "",
            mainImageId: "",
            userRank: nil,
            favoriteYn: false
        )
    ]
    
    func getDefaultQuests(commercialAreaCode: String, orderRewardDesc: Bool?, page: Int, size: Int) async -> Result<ResponseWithPage<[Quest]>, Error> {
        .success(ResponseWithPage(size: size, content: mockQuests, totalPages: 1, totalElements: mockQuests.count, page: page, isLast: true))
    }
    
    func getRepeatQuests(commercialAreaCode: String, repeatFrequency: RepeatType, orderRewardDesc: Bool?, page: Int, size: Int) async -> Result<ResponseWithPage<[Quest]>, Error> {
        .success(ResponseWithPage(size: size, content: mockRepeatQuests, totalPages: 1, totalElements: mockQuests.count, page: page, isLast: true))
    }
    
    func getEventQuests(commercialAreaCode: String, orderRewardDesc: Bool?, orderExpiredDesc: Bool?, page: Int, size: Int) async -> Result<ResponseWithPage<[Quest]>, Error> {
        .success(ResponseWithPage(size: size, content: mockEventQuests, totalPages: 1, totalElements: mockQuests.count, page: page, isLast: true))
    }
    
    func getCompletedQuests(page: Int, size: Int) async -> Result<ResponseWithPage<[Quest]>, Error> {
        .success(ResponseWithPage(size: size, content: mockQuests+mockRepeatQuests+mockEventQuests, totalPages: 1, totalElements: mockQuests.count, page: page, isLast: true))
    }
    
    func getRecommendQuests(commercialAreaCode: String, page: Int, size: Int) async -> Result<ResponseWithPage<[Quest]>, Error> {
        .success(ResponseWithPage(size: size, content: mockQuests, totalPages: 1, totalElements: mockQuests.count, page: page, isLast: true))
    }
    
    func getPopularQuests(commercialAreaCode: String, page: Int, size: Int) async -> Result<ResponseWithPage<[Quest]>, Error> {
        .success(ResponseWithPage(size: size, content: mockQuests, totalPages: 1, totalElements: mockQuests.count, page: page, isLast: true))
    }
    
    func getLargeRewardQuests(commercialAreaCode: String, page: Int, size: Int) async -> Result<ResponseWithPage<[Quest]>, Error> {
        .success(ResponseWithPage(size: size, content: mockQuests, totalPages: 1, totalElements: mockQuests.count, page: page, isLast: true))
    }
    
    func getQuestDetail(questId: Int) async -> Result<Quest, Error> {
        if let quest = mockQuests.first(where: { $0.id == questId }) {
            return .success(quest)
        } else {
            return .failure(NSError(domain: "QuestNotFound", code: 404))
        }
    }
}
