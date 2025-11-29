//
//  MissionHistoryViewModel.swift
//  ILSANG
//
//  Created by Lee Jinhee on 8/28/25.
//


import UIKit
// 미션 타입이 변할 때 -> 데이터가 비어있을 경우에만 API 호출
// 필터 타입이 변할 때 -> API 호출
final class UserMissionHistoryViewModel: ObservableObject, CategoryPaginationLoadable {
    // MARK: - Typealias
    typealias Item = UserMissionHistoryItem
    typealias Category = MissionType
    
    // MARK: - Published Properties
    @Published var viewStatus: ViewStatus = .loading
    @Published var missionHistories: [MissionType: [Item]] = [:]
    @Published var selectedMissionHistoryDetail: UserMissionHistoryDetailItem?
    @Published var selectedMissionType: MissionType = .photo
    @Published var challengeDelete = false
    
    // MARK: - Computed Properties
    var currentItems: [Item] {
        switch selectedMissionType {
        case .photo:
            return missionHistories[.photo, default: []]
        case .quiz(.ox):
            return missionHistories[.quiz(.ox), default: []]
        case .quiz(.text):
            return missionHistories[.quiz(.text), default: []]
        }
    }
    
    // MARK: - Stored Properties
    var filterState = StaticFilterPickerState<MissionHistoryFilterType>(initialValue: .latest)
    
    private let photoPaginationManager = PaginationManager<Item>(size: 10, threshold: 3)
    private let oxPaginationManager = PaginationManager<Item>(size: 10, threshold: 3)
    private let textPaginationManager = PaginationManager<Item>(size: 10, threshold: 3)
    
    private let missionHistoryRepository: MissionHistoryRepositoryInterface
    
    init(missionHistoryRepository: MissionHistoryRepositoryInterface, challengeDelete: Bool = false) {
        self.missionHistoryRepository = missionHistoryRepository
        setupFilterStateObserver()
        setupPaginationManagers()
    }
    
    private func setupFilterStateObserver() {
        filterState.onSelectionChange = { [weak self] _ in
            guard let self = self else { return }
            Task {
                await self.loadInitialDataWithLoadingState()
            }
        }
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
        if isCurrentListEmpty {
            await loadInitialDataWithLoadingState()
        }
    }
    
    private func loadInitialDataWithLoadingState() async {
        await changeViewStatus(.loading)
        let minimumDelay: UInt64 = 300_000_000 // 최소 응답 지연 시간 추가 (0.3초)
        async let dataLoad: Void = loadInitialData()
        async let delay: Void = Task.sleep(nanoseconds: minimumDelay)
        _ = try? await (dataLoad, delay)
        await changeViewStatus(.loaded)
    }
    
    @MainActor
    func loadPageData(page: Int, size: Int, category: Category) async -> Bool {
        let response = await fetchMissionHistories(
            page: page,
            size: size,
            missionType: category,
            filterType: filterState.selectedValue
        )
        
        let newItems = response.data
        
        // 현재 카테고리에 맞는 기존 데이터
        if page == 0 {
            self.missionHistories[category, default: []] = newItems
        } else {
            self.missionHistories[category, default: []] += newItems
        }
        
        // category가 .photo일 때만 이미지 로딩 수행
        if case .photo = category {
            await withTaskGroup(of: (Int, UIImage?).self) { group in
                for (index, challenge) in newItems.enumerated() {
                    group.addTask {
                        guard let imageId = challenge.submitImageId else {
                            return (index, nil)
                        }
                        let image = await ImageCacheService.shared.loadImageAsync(imageId: imageId)
                        return (index, image)
                    }
                }
                
                for await (index, image) in group {
                    guard let image else { continue }
                    
                    if page == 0 {
                        self.missionHistories[.photo, default: []][index].submitImage = image
                    } else {
                        let startIndex = (self.missionHistories[.photo]?.count ?? 0) - newItems.count
                        let targetIndex = startIndex + index
                        if self.missionHistories[.photo, default: []].indices.contains(targetIndex) {
                            self.missionHistories[.photo, default: []][targetIndex].submitImage = image
                        }
                    }
                }
            }
        }
        
        return response.isLast
    }
    
    private func fetchMissionHistories(page: Int, size: Int, missionType: MissionType, filterType: MissionHistoryFilterType) async -> (data: [Item], isLast: Bool) {
        let response = await missionHistoryRepository.getMissionHistories(page: page, size: size, userId: nil, missionType: missionType, filterType: filterType)
        
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
    func fetchMissionHistoryDetail(id: Int, submitImage: UIImage?) async {
        let response = await missionHistoryRepository.getMissionHistoryDetail(missionHistoryId: id)
        switch response {
        case .success(let res):
            self.selectedMissionHistoryDetail = res.toItem( submitImage: submitImage)
        case .failure(let error):
            self.selectedMissionHistoryDetail = nil
            Log("챌린지 상세 조회 실패: \(error)")
        }
    }
    
    func deleteMissionHistory(id: Int) async -> Bool {
        return await missionHistoryRepository.deleteMissionHistory(missionHistoryId: id)
    }
    
    func getImage(imageId: String) async -> UIImage? {
        await ImageCacheService.shared.loadImageAsync(imageId: imageId)
    }
    
    func paginationManager(for category: Category) -> PaginationManager<Item> {
        switch category {
        case .photo: return photoPaginationManager
        case .quiz(.ox): return oxPaginationManager
        case .quiz(.text): return textPaginationManager
        }
    }
    
    func closeFilterPicker() {
        self.filterState.pickerStatus  = .close
    }
    
    @MainActor
    func changeViewStatus(_ viewStatus: ViewStatus) {
        self.viewStatus = viewStatus
    }
}

extension UserMissionHistoryViewModel {
    var currentCategory: Category {
        get { selectedMissionType }
        set { selectedMissionType = newValue }
    }
}
