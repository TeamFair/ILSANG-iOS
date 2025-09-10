//
//  QuestViewModel.swift
//  ILSANG
//
//  Created by Lee Jinhee on 5/23/24.
//

import UIKit
import Combine

@Observable
class QuestViewModel {
    // TODO: API 요청 실패 시 에러상태로 변경하기
    enum ViewStatus {
        case error
        case loading
        case loaded
    }
    
     var viewStatus: ViewStatus = .loading
    
    // TODO: 바뀔 때 api 요청하도록 수정 (refresh, init 고려)
     var selectedHeader: QuestStatus = .default
    
     var showSelectMyRegionView: Bool = false
     var alertType: AlertType? = nil
    
    // 필터
     var questFilterState: StaticFilterPickerState<QuestFilterType>
     var repeatFilterState: StaticFilterPickerState<RepeatType>
     var eventFilterState: StaticFilterPickerState<EventQuestFilterType>
       
     var defaultQuestListByFilter: [QuestFilterType: [QuestViewModelItem]] = [:]
     var repeatQuestListByFilter: [RepeatType: [QuestFilterType: [QuestViewModelItem]]] = [:]
     var eventQuestListByFilter: [EventQuestFilterType: [QuestViewModelItem]] = [:]
     var completedQuestList: [QuestViewModelItem] = []

    var currentQuests: [QuestViewModelItem] {
        switch selectedHeader {
        case .default:
            return defaultQuestListByFilter[questFilterState.selectedValue] ?? []
        case .repeat:
            return repeatQuestListByFilter[repeatFilterState.selectedValue]?[questFilterState.selectedValue] ?? []
        case .event:
            return eventQuestListByFilter[eventFilterState.selectedValue] ?? []
        case .completed:
            return completedQuestList
        }
    }
    
    var isCurrentListEmpty: Bool {
        currentQuests.isEmpty
    }
    
    // TODO: 페이지네이션 로직 수정 필요
    let defaultPaginationManager: PaginationManager<QuestViewModelItem>
    let repeatPaginationManager: PaginationManager<QuestViewModelItem>
    let eventPaginationManager: PaginationManager<QuestViewModelItem>
    let completedPaginationManager: PaginationManager<QuestViewModelItem>
    
    // MARK: throttle 관련
    let throttleInterval: TimeInterval = 2.0
    var lastRefreshTime: Date? = nil
    
    private let questRepository: QuestRepositoryInterface
    private let favoriteService: FavoriteService
    private let sharedState: SharedState
        
    private var cancellables = Set<AnyCancellable>()
    
    init(
        questRepository: QuestRepositoryInterface,
        favoriteService: FavoriteService,
        sharedState: SharedState
    ) {
        self.questRepository = questRepository
        self.favoriteService = favoriteService
        self.sharedState = sharedState
        
        questFilterState = StaticFilterPickerState<QuestFilterType>(initialValue: .popular)
        eventFilterState = StaticFilterPickerState<EventQuestFilterType>(initialValue: .popular)
        repeatFilterState = StaticFilterPickerState<RepeatType>(initialValue: .daily)
        
        self.defaultPaginationManager = PaginationManager(size: 20, threshold: 18)
        self.repeatPaginationManager = PaginationManager(size: 20, threshold: 18)
        self.eventPaginationManager = PaginationManager(size: 20, threshold: 18)
        self.completedPaginationManager = PaginationManager(size: 20, threshold: 18)
        self.defaultPaginationManager.loadPageData = { [weak self] page in
            guard let self = self else { return ([], 0) }
            return await self.loadQuestListWithImage(page: page, size: 20, status: .default)
        }
        self.repeatPaginationManager.loadPageData = { [weak self] page in
            guard let self = self else { return ([], 0) }
            return await self.loadQuestListWithImage(page: page, size: 20, status: .repeat)
        }
        self.eventPaginationManager.loadPageData = { [weak self] page in
            guard let self = self else { return ([], 0) }
            return await self.loadQuestListWithImage(page: page, size: 20, status: .event)
        }
        self.completedPaginationManager.loadPageData = { [weak self] page in
            guard let self = self else { return ([], 0) }
            return await self.loadQuestListWithImage(page: page, size: 10, status: .completed)
        }
        
        questFilterState.onSelectionChange = { [weak self] _ in
            guard let self = self else { return }
            switch selectedHeader {
            case .default:
                Task { await self.defaultPaginationManager.loadData(isRefreshing: true) }
            case .repeat:
                Task { await self.repeatPaginationManager.loadData(isRefreshing: true) }
            default: break
            }
        }
        eventFilterState.onSelectionChange = { [weak self] _ in
            guard let self = self else { return }
            Task { await self.eventPaginationManager.loadData(isRefreshing: true) }
        }
        repeatFilterState.onSelectionChange = { [weak self] _ in
            guard let self = self else { return }
            Task { await self.repeatPaginationManager.loadData(isRefreshing: true) }
        }
        
        Task { await setupBindings() }
    }
    
    @MainActor
    private func setupBindings() {
        sharedState.$selectedCommercialArea
            .removeDuplicates()
            .dropFirst()
            .sink { [weak self] _ in
                Task { await self?.loadInitialData() }
            }
            .store(in: &cancellables)
        
//        questRouter.$showSubmitRouter
//            .removeDuplicates()
//            .dropFirst()
//            .sink { [weak self] isPresented in
//                if !isPresented {
//                    Task { await self?.loadInitialData() }
//                }
//            }
//            .store(in: &cancellables)
//        
//        questRouter.$showQuestEngage
//            .removeDuplicates()
//            .dropFirst()
//            .sink { [weak self] isPresented in
//                if !isPresented {
//                    Task { await self?.loadInitialData() }
//                }
//            }
//            .store(in: &cancellables)
    }
    
    func loadDataIfNeeded() async {
        if isCurrentListEmpty {
            await loadInitialData()
        }
    }
    
    func loadInitialData() async {
        await changeViewStatus(.loading)
        async let defaultLoad: () = defaultPaginationManager.loadData(isRefreshing: true)
        async let repeatLoad: () = repeatPaginationManager.loadData(isRefreshing: true)
        async let eventLoad: () = eventPaginationManager.loadData(isRefreshing: true)
        async let completedLoad: () = completedPaginationManager.loadData(isRefreshing: true)
        _ = await (defaultLoad, repeatLoad, eventLoad, completedLoad)
        await changeViewStatus(.loaded)
    }
    
    func refreshData() async {
        // 마지막 새로고침으로부터 throttleInterval 이내에 새로 고침 시도를 방지
        let now = Date()

        if let lastRefreshTime = lastRefreshTime, now.timeIntervalSince(lastRefreshTime) < throttleInterval {
            return
        }
        lastRefreshTime = now

        switch selectedHeader {
        case .default:
            await defaultPaginationManager.loadData(isRefreshing: true)
        case .repeat:
            await repeatPaginationManager.loadData(isRefreshing: true)
        case .event:
            await eventPaginationManager.loadData(isRefreshing: true)
        case .completed:
            await completedPaginationManager.loadData(isRefreshing: true)
        }
        
        lastRefreshTime = Date()
    }
    
    @MainActor
    func changeViewStatus(_ viewStatus: ViewStatus) {
        self.viewStatus = viewStatus
    }
    
    @discardableResult @MainActor
    func loadQuestListWithImage(
        page: Int,
        size: Int,
        status: QuestStatus,
    ) async -> ([QuestViewModelItem], Int) {
        let getQuestList = await getQuestList(page: page, size: size, status: status)
        var newQuestList = getQuestList.data
        
        // 현재 필터별 existingList 가져오기
        let existingList: [QuestViewModelItem]
        switch status {
        case .default:
            existingList = defaultQuestListByFilter[questFilterState.selectedValue] ?? []
        case .repeat:
            let rFilter = repeatFilterState.selectedValue
            let qFilter = questFilterState.selectedValue
            existingList = repeatQuestListByFilter[rFilter]?[qFilter] ?? []
        case .event:
            let filter = eventFilterState.selectedValue
            existingList = eventQuestListByFilter[filter] ?? []
        case .completed:
            existingList = completedQuestList
        }
        
        // 중복된 항목 제거
        let currentQuestIds = Set(existingList.map { $0.id })
        var seenIds = Set<Int>()
        newQuestList = newQuestList.filter { quest in
            if seenIds.contains(quest.id) || (currentQuestIds.contains(quest.id) && page > 0) {
                return false
            } else {
                seenIds.insert(quest.id)
                return true
            }
        }
        
        var mergedList: [QuestViewModelItem]
        if page == 0 {
            mergedList = newQuestList
        } else {
            mergedList = existingList + newQuestList
        }
        
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
        switch status {
        case .default:
            let questFilter = questFilterState.selectedValue
            mapDefaultQuestByFilter(list: mergedList, filter: questFilter)
        case .repeat:
            mapRepeatQuestByFilter(list: mergedList, repeatType: repeatFilterState.selectedValue, filter: questFilterState.selectedValue)
        case .event:
            mapEventQuestByFilter(list: mergedList, filter: eventFilterState.selectedValue)
        case .completed:
            completedQuestList = mergedList
        }
        
        return (mergedList, getQuestList.total)
    }
    
    /// uncompleted 상태의 기본 퀘스트 목록을 XpStat별로 분류하여 defaultQuestListByXpStat 딕셔너리에 매핑합니다.
    private func mapDefaultQuestByFilter(list: [QuestViewModelItem], filter: QuestFilterType) {
        var mapped = defaultQuestListByFilter
        mapped[filter] = list
        self.defaultQuestListByFilter = mapped
    }
    
    private func mapRepeatQuestByFilter(list: [QuestViewModelItem], repeatType: RepeatType, filter: QuestFilterType) {
        var mapped = repeatQuestListByFilter
        var subMapped = mapped[repeatType] ?? [:]
        subMapped[filter] = list
        mapped[repeatType] = subMapped
        self.repeatQuestListByFilter = mapped
    }
    
    private func mapEventQuestByFilter(list: [QuestViewModelItem], filter: EventQuestFilterType) {
        var mapped = eventQuestListByFilter
        mapped[filter] = list
        self.eventQuestListByFilter = mapped
    }
    
    private func getQuestList(page: Int, size: Int, status: QuestStatus) async -> (data: [QuestViewModelItem], total: Int) {
        let result: Result<ResponseWithPage<[Quest]>, Error>
        
        switch status {
        case .default:
            result = await questRepository.getDefaultQuests(
                commercialAreaCode: sharedState.selectedCommercialArea.code,
                orderRewardDesc: questFilterState.selectedValue.orderRewardDesc,
                page: page,
                size: size
            )
        case .repeat:
            result = await questRepository.getRepeatQuests(
                commercialAreaCode: sharedState.selectedCommercialArea.code,
                repeatFrequency: repeatFilterState.selectedValue,
                orderRewardDesc: questFilterState.selectedValue.orderRewardDesc,
                page: page,
                size: size
            )
        case .event:
            result = await questRepository.getEventQuests(
                commercialAreaCode: sharedState.selectedCommercialArea.code,
                orderRewardDesc: eventFilterState.selectedValue.orderRewardDesc,
                orderExpiredDesc: eventFilterState.selectedValue.orderExpiredDesc,
                page: page,
                size: size
            )
        case .completed:
            result = await questRepository.getCompletedQuests(page: page, size: size)
        }
        
        switch result {
        case .success(let response):
            return (response.content.map { $0.toQuestItem() }, response.totalElements)
        case .failure:
            return ([], 0)
        }
    }
    
    func hasMorePage(status: QuestStatus) -> Bool {
        switch status {
        case .default:
            return defaultPaginationManager.canLoadMoreData()
        case .repeat:
            return repeatPaginationManager.canLoadMoreData()
        case .event:
            return eventPaginationManager.canLoadMoreData()
        case .completed:
            return completedPaginationManager.canLoadMoreData()
        }
    }
    
    func handleMyRegionSelection(_ area: CommercialArea) {
        sharedState.selectedCommercialArea = area
        self.alertType = .myRegionChangeSuccess
    }
    
    /// 즐겨찾기 상태를 UI에 즉시 반영하고,  서버 반영은 디바운싱 처리
    func toggleFavoriteStatus(quest: QuestViewModelItem) {
        favoriteService.toggle(quest: quest)
    }
    
    func closeFilterPicker() {
        self.questFilterState.pickerStatus  = .close
        self.repeatFilterState.pickerStatus = .close
        self.eventFilterState.pickerStatus = .close
    }
}
