//
//  OtherUserProfileViewModel.swift
//  ILSANG
//
//  Created by Lee Jinhee on 3/8/25.
//

import UIKit
import Combine

final class OtherUserProfileViewModel: ObservableObject, CategoryPaginationLoadable {
    // MARK: - Typealias
    typealias Item = UserMissionHistoryItem
    typealias Category = MissionType
    
    let userId: String
    
    @Published private(set) var missionHistoryViewStatus: ViewStatus = .loading
    @Published private(set) var userData: User?
    @Published private(set) var userTotalPoint: Int?
    @Published private(set) var userProfileImage: UIImage?
    
    @Published var selectedSeasonNumber: Int = -1
    
    @Published private(set) var pointCommercial: PointCommercialItem? // 내 일상존
    @Published private(set) var completedQuestCount: Int = 0
    @Published private(set) var points: [PointType: Int] = [:]
    @Published var seasonFilterState: DynamicFilterPickerState<SeasonFilterType>
    
    @Published var selectedMissionType: MissionType = .photo
    @Published private var missionHistories: [MissionType: [Item]] = [:]
    @Published var selectedMissionHistoryDetail: UserMissionHistoryDetailItem?
    
    // MARK: - Computed Properties
    var currentMissionHistories: [Item] {
        switch selectedMissionType {
        case .photo:
            return missionHistories[.photo, default: []]
        case .quiz(.ox):
            return missionHistories[.quiz(.ox), default: []]
        case .quiz(.text):
            return missionHistories[.quiz(.text), default: []]
        }
    }
    
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
    
    // MARK: - Stored Properties
    private let photoPaginationManager = PaginationManager<Item>(size: 10, threshold: 3)
    private let oxPaginationManager = PaginationManager<Item>(size: 10, threshold: 3)
    private let textPaginationManager = PaginationManager<Item>(size: 10, threshold: 3)
    
    private let userRepository: UserRepositoryInterface
    private let missionHistoryRepository: MissionHistoryRepository
    private let areaNameService: AreaNameProvider
    private let seasonManager: SeasonManager
    private var cancellables = Set<AnyCancellable>()
    
    init(userId: String, userRepository: UserRepositoryInterface, missionHistoryRepository: MissionHistoryRepository, areaNameService: AreaNameProvider, seasonManager: SeasonManager) {
        self.userId = userId
        self.userRepository = userRepository
        self.missionHistoryRepository = missionHistoryRepository
        self.areaNameService = areaNameService
        self.seasonManager = seasonManager
        
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
        
        Task { @MainActor in
            selectedSeasonNumber = seasonManager.currentSeason?.seasonNumber ?? -1 // 현재시즌으로 초기화
            updateSeasonsFromServer(seasonManager.seasons.map { $0.seasonNumber })
        }
        
        setupPaginationManagers()
    }
    
    private func setupPaginationManagers() {
        self.photoPaginationManager.loadPageData = { [weak self] page, size in
            guard let self = self else { return true }
            return await loadPageData(page: page, size: size, category: selectedMissionType)
        }
        self.oxPaginationManager.loadPageData = { [weak self] page, size in
            guard let self = self else { return true }
            return await loadPageData(page: page, size: size, category: selectedMissionType)
        }
        self.textPaginationManager.loadPageData = { [weak self] page, size in
            guard let self = self else { return true }
            return await loadPageData(page: page, size: size, category: selectedMissionType)
        }
    }
    
    func loadDataIfNeeded() async {
        if userData != nil {
            return
        } else {
            await loadAllInitialData()
        }
    }
    
    func loadAllInitialData() async {
        async let user: () = fetchUser(userId: userId)
        async let commercial: () = fetchUserPointCommercial()
        async let pointAndQuest: () = fetchPointAndQuestCount()
        async let history: () = loadMissionDataIfNeeded()
        _ = await (user, commercial, pointAndQuest, history)
    }
    
    func loadMissionDataIfNeeded() async {
        if isCurrentListEmpty {
            await loadInitialDataWithLoadingState(for: currentCategory)
        }
    }
    
    private func loadInitialDataWithLoadingState(for category: Category) async {
        await changeViewStatus(.loading)
        let minimumDelay: UInt64 = 300_000_000 // 최소 응답 지연 시간 추가 (0.3초)
        async let dataLoad: Void = loadInitialData(for: category)
        async let delay: Void = Task.sleep(nanoseconds: minimumDelay)
        _ = try? await (dataLoad, delay)
        await changeViewStatus(.loaded)
    }
    
    func loadPageData(page: Int, size: Int, category: Category) async -> Bool {
        switch category {
        case .photo:
            await loadPhotoMissionHistory(page: page, size: size)
        case .quiz(let type):
            await loadQuizMissionHistory(page: page, size: size, quizType: type)
        }
    }
    
    @MainActor
    func loadPhotoMissionHistory(page: Int, size: Int) async -> Bool {
        if page == 0 {
            missionHistoryViewStatus = .loading
        }
        let response = await fetchMissionHistories(page: page, size: size, missionType: .photo)
        let newItems = response.data
        
        await withTaskGroup(of: (Int, UIImage?).self) { group in
            for (index, challenge) in newItems.enumerated() {
                group.addTask {
                    let imageId = challenge.submitImageId
                    guard let imageId else { return (index, nil) }
                    let image = await ImageCacheService.shared.loadImageAsync(imageId: imageId)
                    return (index, image)
                }
            }
            
            for await (index, image) in group {
                if let image {
                    newItems[index].submitImage = image
                }
            }
        }
        
        if page == 0 {
            self.missionHistories[.photo, default: []] = newItems
            missionHistoryViewStatus = .loaded
        } else {
            self.missionHistories[.photo, default: []] += newItems
        }
        
        return response.isLast
    }
    
    @MainActor
    private func loadQuizMissionHistory(page: Int, size: Int, quizType: QuizType) async -> Bool {
        if page == 0 {
            missionHistoryViewStatus = .loading
        }
        let response = await fetchMissionHistories(page: page, size: size, missionType: .quiz(quizType))
        let newItems = response.data
        
        if page == 0 {
            self.missionHistories[.quiz(quizType), default: []] = newItems
            missionHistoryViewStatus = .loaded
        } else {
            self.missionHistories[.quiz(quizType), default: []]  += newItems
        }
        
        return response.isLast
    }
    
    private func fetchMissionHistories(page: Int, size: Int, missionType: MissionType) async -> (data: [UserMissionHistoryItem], isLast: Bool) {
        let response = await missionHistoryRepository.getMissionHistories(page: page, size: size, userId: userId, missionType: missionType, filterType: .latest)
        
        switch response {
        case .success(let res):
            // 데이터 초기화: 이미지가 없는 상태로 미리 표시
            return (res.data.map { $0.toItem() }, res.isLast)
        case .failure(let error):
            Log("챌린지 조회 실패: \(error)")
            return ([], true)
        }
    }
    
    @MainActor
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
    
    @MainActor
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
    
    @MainActor
    func fetchPointAndQuestCount() async {
        let selectedSeasonId = getSelectedSeasonId()
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
    
    @MainActor
    func fetchMissionHistoryDetail(id: Int, submitImage: UIImage?) async {
        let response = await missionHistoryRepository.getMissionHistoryDetail(missionHistoryId: id)
        switch response {
        case .success(let res):
            self.selectedMissionHistoryDetail = res.toItem(submitImage: submitImage)
        case .failure(let error):
            self.selectedMissionHistoryDetail = nil
            Log("챌린지 상세 조회 실패: \(error)")
        }
    }
    
    func getImage(imageId: String) async -> UIImage? {
        await ImageCacheService.shared.loadImageAsync(imageId: imageId)
    }
    
    @MainActor
    func getSelectedSeasonId() -> Int? {
        seasonManager.seasons.first { $0.seasonNumber == selectedSeasonNumber }?.id
    }
    
    func updateSeasonsFromServer(_ seasonNumbers: [Int]) {
        let newOptions = [SeasonFilterType(seasonNumber: -1)] + seasonNumbers.map { SeasonFilterType(seasonNumber: $0) }
        
        // 값이 실제로 바뀌었을 때만 업데이트
        if seasonFilterState.options != newOptions {
            seasonFilterState.updateOptions(newOptions)
        }
    }
    
    @MainActor
    func changeViewStatus(_ viewStatus: ViewStatus) {
        self.missionHistoryViewStatus = viewStatus
    }
    
    internal func paginationManager(for category: Category) -> PaginationManager<Item> {
        switch category {
        case .photo: return photoPaginationManager
        case .quiz(.ox): return oxPaginationManager
        case .quiz(.text): return textPaginationManager
        }
    }
}

extension OtherUserProfileViewModel {
    var currentCategory: Category {
        get { selectedMissionType }
        set { selectedMissionType = newValue }
    }
    
    var currentItems: [Item] {
        get { currentMissionHistories }
    }
}
