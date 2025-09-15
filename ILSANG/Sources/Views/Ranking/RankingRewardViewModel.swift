//
//  RankingRewardViewModel.swift
//  ILLSANG
//
//  Created by Lee Jinhee on 9/16/25.
//

import Foundation

class RankingRewardViewModel: ObservableObject {
    enum ViewStatus {
        case error
        case loading
        case loaded
    }
    
    enum AreaType {
        case metro
        case commercial
    }
    @Published var viewStatus: ViewStatus = .loading
    @Published var pointType: PointType = .metro
    @Published private var rewards: [PointType: [TitleItem]] = [:]
    var currentRewards: [TitleItem] {
        rewards[pointType, default: []]
    }
    private let titleRepository: TitleRepositoryInterface
    
    init(
        titleRepository: TitleRepositoryInterface
    ) {
        self.titleRepository = titleRepository
    }
    
    @MainActor
    func loadRewardsIfNeeded(pointType: PointType) async {
        if let rewards = rewards[pointType], !rewards.isEmpty {
            return
        }
        
        await getRewards(pointType: pointType)
    }
    
    @MainActor
    func getRewards(pointType: PointType) async {
        viewStatus = .loading
        
        let res = await titleRepository.getSeasonTitles(type: pointType)
        
        switch res {
        case .success(let reward):
            self.rewards[pointType, default: []] = reward.map { $0.toItem() }
            viewStatus = .loaded
        case .failure:
            viewStatus = .error
        }
    }
}
