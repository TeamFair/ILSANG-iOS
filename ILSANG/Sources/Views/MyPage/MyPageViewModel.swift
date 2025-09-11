//
//  MyPageViewModel.swift
//  ILSANG
//
//  Created by Kim Andrew on 6/25/24.
//

import UIKit
import SwiftUICore
import Combine

struct XpStatus {
    let currentXp: Int
    let currentLv: Int
    let remainXp: Int
    let progress: Double
    
    init(currentXp: Int) {
        self.currentXp = currentXp
        self.currentLv = XpLevelCalculator.convertXPtoLv(xp: currentXp)
        self.remainXp = XpLevelCalculator.xpForNextLv(xp: currentXp)
        
        let levelData = XpLevelCalculator.xpProgressInCurrentLevel(xp: currentXp, level: currentLv)
        self.progress = XpLevelCalculator.calculateProgress(
            currentValue: levelData.currentLevelXP,
            totalValue: levelData.requiredXPForNextLevel
        )
    }
}

@MainActor
final class MyPageViewModel: ObservableObject {
    @Published var currentUser: UserItem?
    @Published var xpStatus: XpStatus = XpStatus(currentXp: 0)
    
    @Published var pointCommercial: PointCommercialItem? // 내 일상존
    @Published var completedQuestCount: Int = 0
    @Published var points: [PointType: Int] = [:]
    @Published var pointSummary: PointSummaryItem? // 시즌 요약
    
    @Published var currentSeason: Season? = nil
    @Published var seasonFilterState: DynamicFilterPickerState<SeasonFilterType>
    @Published var selectedSeasonNumber: Int = -1
    var selectedSeasonId: Int? {
        seasonManager.seasons.first { $0.seasonNumber == selectedSeasonNumber }?.id
    }
    
    private let userRepository: UserRepositoryInterface
    private let imageNetwork: ImageNetwork
    private let areaNameService: AreaNameProvider
    private let seasonManager: SeasonManager
    private var cancellables = Set<AnyCancellable>()
    
    init(userRepository: UserRepositoryInterface, imageNetwork: ImageNetwork, areaNameService: AreaNameProvider, seasonManager: SeasonManager) {
        self.userRepository = userRepository
        self.imageNetwork = imageNetwork
        self.areaNameService = areaNameService
        self.seasonManager = seasonManager
        
        self.currentUser = UserService.shared.currentUser
        
        // 초기값을 -1로 통일
        seasonFilterState = DynamicFilterPickerState(
            initialValue: SeasonFilterType(seasonNumber: -1),
            options: [SeasonFilterType(seasonNumber: -1)]
        )
        seasonFilterState.onSelectionChange = { [weak self] selectedValue in
            guard let self = self else { return }
            // 선택된 시즌 번호 업데이트
            self.selectedSeasonNumber = selectedValue.seasonNumber
            Task { await self.fetchPointAndQuestCount() }
        }
        
        updateSeasonsFromServer(seasonManager.seasons.map { $0.seasonNumber })
        selectedSeasonNumber = seasonManager.currentSeason?.seasonNumber ?? -1 // 현재시즌으로 초기화
        
        currentSeason = seasonManager.currentSeason ?? nil
        seasonManager.$currentSeason
            .dropFirst()
            .removeDuplicates()
            .sink { [weak self] season in
                guard let self else { return }
                self.currentSeason = season
            }
            .store(in: &cancellables)
        seasonManager.$seasons
            .dropFirst()
            .removeDuplicates()
            .sink { [weak self] seasons in
                guard let self else { return }
                self.updateSeasonsFromServer(seasons.map { $0.seasonNumber })
            }
            .store(in: &cancellables)
    }
    
    func updateSeasonsFromServer(_ seasonNumbers: [Int]) {
        let options = [SeasonFilterType(seasonNumber: -1)] + seasonNumbers.map { SeasonFilterType(seasonNumber: $0) }
        seasonFilterState.updateOptions(options)
    }
    
    @MainActor
    func loadData() async {
        async let user: () = fetchUser()
        async let commercial: () = fetchUserPointCommercial()
        async let pointAndQuest: () = fetchPointAndQuestCount()
        async let summary: () = fetchUserPointSummary()
        
        _ = await (user, commercial, pointAndQuest, summary)
        
        self.xpStatus = XpStatus(currentXp: points.reduce(0) { $0 + $1.value })
    }
    
    @MainActor
    func refreshData() async {
        async let user: () = fetchUser()
        async let commercial: () = fetchUserPointCommercial()
        async let pointAndQuest: () = fetchPointAndQuestCount()
        async let summary: () = fetchUserPointSummary()
        
        _ = await (user, commercial, pointAndQuest, summary)
    }
    
    @MainActor
    func fetchUser() async {
        let res = await userRepository.getUser()
        switch res {
        case .success(let res):
            self.currentUser = res.toItem()
            if let profileImageId = res.profileImageId {
                self.currentUser?.profileImage = await getImage(imageId: profileImageId)
            }
        case .failure:
            self.currentUser = nil
        }
    }
    
    func fetchUserPointCommercial() async {
        let res = await userRepository.getUserPointCommercial(userId: nil)
        
        switch res {
        case .success(let res):
            self.pointCommercial = res.toItem()
            if let commercialAreaCode = pointCommercial?.topCommercialArea?.commercialAreaCode {
                self.pointCommercial?.topCommercialArea?.commercialAreaName = await areaNameService.getAreaName(for: commercialAreaCode)
            }
            for i in 0..<(self.pointCommercial?.totalOwnerContributions.count ?? 0) {
                if let commercialAreaCode = self.pointCommercial?.totalOwnerContributions[i].commercialAreaCode {
                    let name = await areaNameService.getAreaName(for: commercialAreaCode)
                    self.pointCommercial?.totalOwnerContributions[i].commercialAreaName = name
                }
            }
        case .failure(let error):
            Log("일상존 포인트 조회 실패: \(error)")
        }
    }
    
    @MainActor
    func fetchPointAndQuestCount() async {
        let res = await userRepository.getUserPoint(userId: nil, seasonId: selectedSeasonId)
        
        switch res {
        case .success(let res):
            self.completedQuestCount = res.completedQuestCount
            self.points = [
                .metro: res.metroAreaPoint,
                .commercial: res.commercialAreaPoint,
                .contribution: res.contributionPoint
            ]
        case .failure(let error):
            Log("포인트 조회 실패: \(error)")
        }
    }
    
    func fetchUserPointSummary() async {
        guard let currentSeasonId = currentSeason?.id else {
            pointSummary = nil
            return
        }
        let res = await userRepository.getUserPointSummary(seasonId: currentSeasonId)
        
        switch res {
        case .success(let res):
            self.pointSummary = res.toItem()
            if let commercialAreaCode = pointSummary?.topCommercialAreaCode {
                self.pointSummary?.topCommercialAreaName = await areaNameService.getAreaName(for: commercialAreaCode)
            }
            if let metroAreaCode = pointSummary?.topMetroAreaCode {
                self.pointSummary?.topMetroAreaName = await areaNameService.getAreaName(for: metroAreaCode)
            }
        case .failure(let error):
            Log("시즌 요약 조회 실패: \(error)")
        }
    }
    
    func getImage(imageId: String) async -> UIImage? {
        await ImageCacheService.shared.loadImageAsync(imageId: imageId)
    }
}
