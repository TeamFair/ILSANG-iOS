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
    func getFavoriteQuests(commercialAreaCode: String, page: Int, size: Int) async -> Result<ResponseWithPage<[Quest]>, Error>
    func getRecommendQuests(commercialAreaCode: String, page: Int, size: Int) async -> Result<ResponseWithPage<[Quest]>, Error>
    func getPopularQuests(commercialAreaCode: String, page: Int, size: Int) async -> Result<ResponseWithPage<[Quest]>, Error>
    func getLargeRewardQuests(commercialAreaCode: String, page: Int, size: Int) async -> Result<ResponseWithPage<[Quest]>, Error>
    func getBannerQuests(bannerId: Int, completedYn: Bool, orderRewardDesc: Bool?, orderExpiredDesc: Bool?, page: Int, size: Int) async -> Result<ResponseWithPage<[Quest]>, Error>
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
    
    func getFavoriteQuests(commercialAreaCode: String, page: Int, size: Int) async -> Result<ResponseWithPage<[Quest]>, Error> {
        let res = await network.getFavoriteQuests(commercialAreaCode: commercialAreaCode, page: page, size: size)
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
    
    func getBannerQuests(bannerId: Int, completedYn: Bool, orderRewardDesc: Bool?, orderExpiredDesc: Bool?, page: Int, size: Int) async -> Result<ResponseWithPage<[Quest]>, Error> {
        let res = await network.getBannerQuests(bannerId: bannerId, completedYn: completedYn, orderRewardDesc: orderRewardDesc, orderExpiredDesc: orderExpiredDesc, page: page, size: size)
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
            coupons: [Coupon(id: 0, name: "쿠폰", imageId: nil, storeName: "가게", description: "", validFrom: .now, validTo: .now)],
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
            coupons: [Coupon(id: 0, name: "쿠폰", imageId: nil, storeName: "가게", description: "", validFrom: .now, validTo: .now)],
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
            coupons: [],
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
    
    func getFavoriteQuests(commercialAreaCode: String, page: Int, size: Int) async -> Result<ResponseWithPage<[Quest]>, any Error> {
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
    
    func getBannerQuests(bannerId: Int, completedYn: Bool, orderRewardDesc: Bool?, orderExpiredDesc: Bool?, page: Int, size: Int) async -> Result<ResponseWithPage<[Quest]>, any Error> {
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
