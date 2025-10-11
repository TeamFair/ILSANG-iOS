//
//  OtherUserProfileViewModel.swift
//  ILSANG
//
//  Created by Lee Jinhee on 3/8/25.
//

import UIKit
import Combine

@MainActor
final class OtherUserProfileViewModel: ObservableObject {
    let userId: String

    @Published var userData: User?
    @Published var userTotalPoint: Int?
    @Published var userProfileImage: UIImage?
    
    @Published var selectedSeasonNumber: Int = -1
    var selectedSeasonId: Int? {
        seasonManager.seasons.first { $0.seasonNumber == selectedSeasonNumber }?.id
    }
    
    @Published var pointCommercial: PointCommercialItem? // 내 일상존
    @Published var completedQuestCount: Int = 0
    @Published var points: [PointType: Int] = [:]
    @Published var challengeList: [UserMissionHistoryItem] = []
    
    @Published var seasonFilterState: DynamicFilterPickerState<SeasonFilterType>

    var challengePaginationManager = PaginationManager<UserMissionHistoryItem>(
        size: 10,
        threshold: 7)
    
    private let userRepository: UserRepositoryInterface
    private let missionHistoryRepository: MissionHistoryRepository
    private let areaNameService: AreaNameProvider
    private let seasonManager: SeasonManager
    private var cancellables = Set<AnyCancellable>()
    
    var userPoint: Int {
        points.reduce(0) { $0 + $1.value }
    }
    var currentLv: Int {
        XpLevelCalculator.convertXPtoLv(xp: userPoint)
    }
    var progress: Double {
        let levelData = XpLevelCalculator.xpProgressInCurrentLevel(xp: userPoint, level: currentLv)
        return XpLevelCalculator.calculateProgress(currentValue: levelData.currentLevelXP, totalValue: levelData.requiredXPForNextLevel)
    }
    
    init(userId: String, userRepository: UserRepositoryInterface, missionHistoryRepository: MissionHistoryRepository, areaNameService: AreaNameProvider, seasonManager: SeasonManager) {
        self.userId = userId
        self.userRepository = userRepository
        self.missionHistoryRepository = missionHistoryRepository
        self.areaNameService = areaNameService
        self.seasonManager = seasonManager
        
        selectedSeasonNumber = seasonManager.currentSeason?.seasonNumber ?? -1 // 현재시즌으로 초기화

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
        
        challengePaginationManager.loadPageData = { [weak self] page in
            guard let self = self else { return ([], 0) }
            return await loadChallengeListWithImage(page: page, size: 10)
        }
    }
    
    func loadDataIfNeeded() async {
        if userData != nil {
            return
        } else {
            await loadInitialData()
        }
    }
    
    func loadInitialData() async {
        async let user: () = fetchUser(userId: userId)
        async let commercial: () = fetchUserPointCommercial()
        async let pointAndQuest: () = fetchPointAndQuestCount()
        async let history: () =  challengePaginationManager.loadData(isRefreshing: true)
        _ = await (user, commercial, pointAndQuest, history)
    }
    
    @discardableResult
    func loadChallengeListWithImage(page: Int, size: Int) async -> ([UserMissionHistoryItem], Int) {
        let getChallengeList = await fetchChallenges(page: page, size: size)
        let newChallengeList = getChallengeList.data
        
        await withTaskGroup(of: (Int, UIImage?).self) { group in
            for (index, challenge) in newChallengeList.enumerated() {
                group.addTask {
                    let imageId = challenge.submitImageId
                    guard let imageId else { return (index, nil) }
                    let image = await ImageCacheService.shared.loadImageAsync(imageId: imageId)
                    return (index, image)
                }
            }

            for await (index, image) in group {
                if let image {
                    newChallengeList[index].submitImage = image
                }
            }
        }
        
        if page == 0 {
            self.challengeList = newChallengeList
        } else {
            self.challengeList += newChallengeList
        }
        
        return (challengeList, getChallengeList.total)
    }
    
    private func fetchChallenges(page: Int, size: Int) async -> (data: [UserMissionHistoryItem], total: Int) {
        let response = await missionHistoryRepository.getMissionHistories(page: page, size: size, userId: userId)
        
        switch response {
        case .success(let res):
            // 데이터 초기화: 이미지가 없는 상태로 미리 표시
            return (res.data.map { $0.toItem() } , res.total)
        case .failure(let error):
            Log("챌린지 조회 실패: \(error)")
            return ([], 0)
        }
    }
    
    func fetchUser(userId: String) async {
        let res = await userRepository.getUser(userId: userId)
        
        switch res {
        case .success(let res):
            self.userData = res
            self.userProfileImage = await ImageCacheService.shared.loadImageAsync(imageId: res.profileImageId ?? "")
        case .failure(let error):
            self.userData = nil
            Log("사용자 정보 조회 실패: \(error)")
        }
    }
    
    func fetchUserPointCommercial() async {
        let res = await userRepository.getUserPointCommercial(userId: userId)
        
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
    
    func fetchPointAndQuestCount() async {
        let res = await userRepository.getUserPoint(userId: userId, seasonId: selectedSeasonId)
        
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
    
    func getImage(imageId: String) async -> UIImage? {
        await ImageCacheService.shared.loadImageAsync(imageId: imageId)
    }
    
    func hasMorePage() -> Bool {
        challengePaginationManager.canLoadMoreData()
    }
    
    
    func updateSeasonsFromServer(_ seasonNumbers: [Int]) {
        let newOptions = [SeasonFilterType(seasonNumber: -1)] + seasonNumbers.map { SeasonFilterType(seasonNumber: $0) }
        
        // 값이 실제로 바뀌었을 때만 업데이트
        if seasonFilterState.options != newOptions {
            seasonFilterState.updateOptions(newOptions)
        }
    }
}
