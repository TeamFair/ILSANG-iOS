//
//  BannerDetailViewModel.swift
//  ILSANG
//
//  Created by Lee Jinhee on 8/16/25.
//

import Combine
import UIKit

class BannerDetailViewModel: ObservableObject, CategoryPaginationLoadable {
    // MARK: - Typealias
    typealias Item = QuestItem
    typealias Category = BannerQuestStatus
    
    // MARK: - Published Properties
    @Published var viewStatus: ViewStatus = .loading
    @Published var banner: BannerItem
    @Published private var uncompletedQuestListByFilter: [EventQuestFilterType: [QuestItem]] = [:]
    @Published private var completedEventQuestListByFilter: [EventQuestFilterType: [QuestItem]] = [:]
    @Published var currentCategory: Category = .uncomplete
    
    // MARK: - Computed Properties
    var currentItems: [QuestItem] {
        (currentCategory == .uncomplete)
        ? uncompletedQuestListByFilter[eventFilterState.selectedValue, default: []]
        : completedEventQuestListByFilter[eventFilterState.selectedValue, default: []]
    }
    
    // MARK: - Stored Properties
    let eventFilterState: StaticFilterPickerState<EventQuestFilterType>
    
    private let uncompletedPaginationManager: PaginationManager<QuestItem>
    private let completedPaginationManager: PaginationManager<QuestItem>
    
    private var refreshTask: Task<Void, Never>?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Dependencies
    private let userRepository: UserRepositoryInterface
    private let questRepository: QuestRepositoryInterface
    private let areaRepository: AreaRepositoryInterface
    private let favoriteService: FavoriteService
    private let illsangZoneManager: IllsangZoneManager
    private let questSubmissionNotifier: QuestSubmissionNotifier
    
    init(
        banner: BannerItem,
        userRepository: UserRepositoryInterface,
        questRepository: QuestRepositoryInterface,
        areaRepository: AreaRepositoryInterface,
        favoriteService: FavoriteService,
        illsangZoneManager: IllsangZoneManager,
        questSubmissionNotifier: QuestSubmissionNotifier
    ) {
        self.banner = banner
        self.userRepository = userRepository
        self.questRepository = questRepository
        self.areaRepository = areaRepository
        self.favoriteService = favoriteService
        self.illsangZoneManager = illsangZoneManager
        self.questSubmissionNotifier = questSubmissionNotifier
        
        self.eventFilterState = StaticFilterPickerState(initialValue: .upcoming)
        self.uncompletedPaginationManager = PaginationManager(size: 10, threshold: 2)
        self.completedPaginationManager = PaginationManager(size: 10, threshold: 2)
        
        setupFilterStateObserver()
        setupPaginationManagers()
        Task { await setupBindings() }
        Log("🎪 BannerDetailViewModel init")
    }
    
    deinit {
        refreshTask?.cancel()
        refreshTask = nil
        cancellables.removeAll()
        Log("🎪 BannerDetailViewModel deinit")
    }
    
    private func setupFilterStateObserver() {
        eventFilterState.onSelectionChange = { [weak self] _ in
            Task {
                await self?.loadInitialData()
            }
        }
    }
    
    private func setupPaginationManagers() {
        uncompletedPaginationManager.loadPageData = { [weak self] page, size in
            guard let self else { return true }
            return await self.loadPageData(page: page, size: size, category: .uncomplete)
        }
        
        completedPaginationManager.loadPageData = { [weak self] page, size in
            guard let self else { return true }
            return await self.loadPageData(page: page, size: size, category: .complete)
        }
    }
    
    @MainActor
    private func setupBindings() {
        questSubmissionNotifier.$refreshTrigger
            .removeDuplicates()
            .dropFirst()
            .sink { [weak self] _ in
                Log("🏠 BannerDetailViewModel: 퀘스트 제출 완료 > 리프레시 예정")
                Task {
                    self?.refreshData()
                }
            }
            .store(in: &cancellables)
    }
    
    func loadDataIfNeeded() async {
        if isCurrentListEmpty {
            await loadAllInitialData()
        }
    }
    
    /// 리프레시 요청
    func refreshData() {
        refreshTask?.cancel()
        refreshTask = Task { [weak self] in
            await self?.loadAllInitialData()
        }
    }
    
    func loadAllInitialData() async {
        await changeViewStatus(.loading)
        async let eventLoad: () = uncompletedPaginationManager.loadData(isRefreshing: true)
        async let completedLoad: () = completedPaginationManager.loadData(isRefreshing: true)
        _ = await (eventLoad, completedLoad)
        await changeViewStatus(.loaded)
    }
    
    @MainActor
    func loadPageData(
        page: Int,
        size: Int,
        category: Category,
    ) async -> Bool {
        let getQuestList = await getQuestList(page: page, size: size, category: category)
        let newQuestList = getQuestList.data
        
        // 현재 필터별 existingList 가져오기
        let existingList: [QuestItem]
        let filter = eventFilterState.selectedValue
        
        switch category {
        case .uncomplete:
            existingList = uncompletedQuestListByFilter[filter] ?? []
        case .complete:
            existingList = completedEventQuestListByFilter[filter] ?? []
        }
        
        let mergedList: [QuestItem] = page == 0 ? newQuestList : existingList + newQuestList
        
        await withTaskGroup(of: (Int, UIImage?).self) { group in
            for (index, quest) in newQuestList.enumerated() {
                group.addTask {
                    guard let imageId = quest.imageId else {
                        return (index, nil)
                    }
                    let image = await ImageCacheService.shared.loadImageAsync(imageId: imageId)
                    return (index, image)
                }
            }
            
            for await (index, image) in group {
                if let image = image {
                    if page == 0 {
                        mergedList[index].image = image
                    } else {
                        mergedList[mergedList.count - newQuestList.count + index].image = image
                    }
                }
            }
        }
        
        // 상태별 필터 매핑
        updateQuestList(mergedList, for: eventFilterState.selectedValue, category: category)
        
        return getQuestList.isLast
    }
    
    @MainActor
    private func updateQuestList(_ list: [QuestItem], for filter: EventQuestFilterType, category: BannerQuestStatus) {
        switch category {
        case .uncomplete:
            uncompletedQuestListByFilter[filter] = list
        case .complete:
            completedEventQuestListByFilter[filter] = list
        }
    }
    
    private func getQuestList(page: Int, size: Int, category status: Category) async -> (data: [Item], isLast: Bool) {
        let result = await questRepository.getBannerQuests(
            bannerId: banner.id,
            completedYn: status == .complete,
            orderRewardDesc: eventFilterState.selectedValue.orderRewardDesc,
            orderExpiredDesc: eventFilterState.selectedValue.orderExpiredDesc,
            page: page,
            size: size
        )
        let myCommercialCode = await MainActor.run { illsangZoneManager.currentZoneCode }
        
        switch result {
        case .success(let response):
            return (response.content.map { $0.toQuestItem(myCommercialCode: myCommercialCode, questCommercialCode: nil) }, response.isLast)
        case .failure:
            // TODO: error 화면 변경
            return ([], true)
        }
    }
    
    func paginationManager(for status: BannerQuestStatus) -> PaginationManager<Item> {
        switch status {
        case .uncomplete:
            return uncompletedPaginationManager
        case .complete:
            return completedPaginationManager
        }
    }
    
    func closeFilterPicker() {
        self.eventFilterState.pickerStatus = .close
    }
    
    /// 즐겨찾기 상태를 UI에 즉시 반영하고,  서버 반영은 디바운싱 처리
    func toggleFavoriteStatus(quest: QuestItem) {
        favoriteService.toggle(quest: quest)
    }
    
    @MainActor
    func changeViewStatus(_ viewStatus: ViewStatus) {
        self.viewStatus = viewStatus
    }
}
