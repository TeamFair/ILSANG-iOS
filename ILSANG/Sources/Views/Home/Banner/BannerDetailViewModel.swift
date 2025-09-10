//
//  BannerDetailViewModel.swift
//  ILSANG
//
//  Created by Lee Jinhee on 8/16/25.
//


import UIKit

class BannerDetailViewModel: ObservableObject {
    @Published var viewStatus: ViewStatus = .loading
    @Published var banner: BannerViewModelItem
    @Published var uncompletedQuestListByFilter: [EventQuestFilterType: [QuestViewModelItem]] = [:]
    @Published var completedEventQuestListByFilter: [EventQuestFilterType: [QuestViewModelItem]] = [:]
    
    @Published var selectedHeader: BannerQuestStatus = .uncomplete
    let eventFilterState: StaticFilterPickerState<EventQuestFilterType>
    
    var filteredQuestList: [QuestViewModelItem] {
        return (selectedHeader == .uncomplete)
        ? uncompletedQuestListByFilter[eventFilterState.selectedValue, default: []]
        : completedEventQuestListByFilter[eventFilterState.selectedValue, default: []]
    }
    
    var isFilteredListEmpty: Bool {
        filteredQuestList.isEmpty
    }
    let uncompletedPaginationManager: PaginationManager<QuestViewModelItem>
    let completedPaginationManager: PaginationManager<QuestViewModelItem>

    private var refreshTask: Task<Void, Never>?

    private let userRepository: UserRepositoryInterface
    private let questRepository: QuestRepositoryInterface
    private let areaRepository: AreaRepositoryInterface
    private let favoriteService: FavoriteService
    
    init(
        banner: BannerViewModelItem,
        userRepository: UserRepositoryInterface,
        questRepository: QuestRepositoryInterface,
        areaRepository: AreaRepositoryInterface,
        favoriteService: FavoriteService
    ) {
        self.banner = banner
        self.userRepository = userRepository
        self.questRepository = questRepository
        self.areaRepository = areaRepository
        self.favoriteService = favoriteService
        
        self.eventFilterState = StaticFilterPickerState(initialValue: .upcoming)
        self.uncompletedPaginationManager = PaginationManager(size: 20, threshold: 18)
        self.completedPaginationManager = PaginationManager(size: 20, threshold: 18)
        
        setupFilterStateObserver()
        setupPaginationManagers()
    }
    
    deinit {
        refreshTask?.cancel()
        refreshTask = nil
        print("🗑️ BannerDetailViewModel deinit")
    }
    
    private func setupFilterStateObserver() {
        eventFilterState.onSelectionChange = { [weak self] _ in
            Task {
                await self?.loadInitialData()
            }
        }
    }
    
    private func setupPaginationManagers() {
        uncompletedPaginationManager.loadPageData = { [weak self] page in
            guard let self = self else { return ([], 0) }
            return await self.loadQuestListWithImage(page: page, size: 20, status: .uncomplete)
        }
        
        completedPaginationManager.loadPageData = { [weak self] page in
            guard let self = self else { return ([], 0) }
            return await self.loadQuestListWithImage(page: page, size: 10, status: .complete)
        }
    }
    
    func loadDataIfNeeded() async {
        if isFilteredListEmpty {
            await loadInitialData()
        }
    }
    
    /// 리프레시 요청
    func refreshData() {
        refreshTask?.cancel()
        refreshTask = Task { [weak self] in
            await self?.loadInitialData()
        }
    }
    
    func loadInitialData() async {
        await changeViewStatus(.loading)
        async let eventLoad: () = uncompletedPaginationManager.loadData(isRefreshing: true)
        async let completedLoad: () = completedPaginationManager.loadData(isRefreshing: true)
        _ = await (eventLoad, completedLoad)
        await changeViewStatus(.loaded)
    }
    
    
    @discardableResult @MainActor
    private func loadQuestListWithImage(
        page: Int,
        size: Int,
        status: BannerQuestStatus,
    ) async -> ([QuestViewModelItem], Int) {
        let getQuestList = await getQuestList(page: page, size: size, status: status)
        let newQuestList = getQuestList.data
        
        // 현재 필터별 existingList 가져오기
        let existingList: [QuestViewModelItem]
        let filter = eventFilterState.selectedValue
        
        switch status {
        case .uncomplete:
            existingList = uncompletedQuestListByFilter[filter] ?? []
        case .complete:
            existingList = completedEventQuestListByFilter[filter] ?? []
        }
        
        let mergedList: [QuestViewModelItem] = page == 0 ? newQuestList : existingList + newQuestList
        
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
        updateQuestList(mergedList, for: eventFilterState.selectedValue, status: status)
        
        return (mergedList, getQuestList.total)
    }
    
    @MainActor
    private func updateQuestList(_ list: [QuestViewModelItem], for filter: EventQuestFilterType, status: BannerQuestStatus) {
        switch status {
        case .uncomplete:
            uncompletedQuestListByFilter[filter] = list
        case .complete:
            completedEventQuestListByFilter[filter] = list
        }
    }
    
    private func getQuestList(page: Int, size: Int, status: BannerQuestStatus) async -> (data: [QuestViewModelItem], total: Int) {
        let result = await questRepository.getBannerQuests(
            bannerId: banner.id,
            completedYn: status == .complete,
            orderRewardDesc: eventFilterState.selectedValue.orderRewardDesc,
            orderExpiredDesc: eventFilterState.selectedValue.orderExpiredDesc,
            page: page,
            size: size
        )
        
        switch result {
        case .success(let response):
            return (response.content.map { $0.toQuestItem() }, response.totalElements)
        case .failure:
            // TODO: error 화면 변경
            return ([], 0)
        }
    }
    
    func hasMorePage(status: BannerQuestStatus) -> Bool {
        switch status {
        case .uncomplete:
            return uncompletedPaginationManager.canLoadMoreData()
        case .complete:
            return completedPaginationManager.canLoadMoreData()
        }
    }
    
    func closeFilterPicker() {
        self.eventFilterState.pickerStatus = .close
    }
    
    /// 즐겨찾기 상태를 UI에 즉시 반영하고,  서버 반영은 디바운싱 처리
    func toggleFavoriteStatus(quest: QuestViewModelItem) {
        favoriteService.toggle(quest: quest)
    }
    
    @MainActor
    func changeViewStatus(_ viewStatus: ViewStatus) {
        self.viewStatus = viewStatus
    }
}
