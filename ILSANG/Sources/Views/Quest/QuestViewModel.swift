//
//  QuestViewModel.swift
//  ILSANG
//
//  Created by Lee Jinhee on 5/23/24.
//

import Combine
import UIKit

final class QuestViewModel: ObservableObject, CategoryPaginationLoadable {
    // MARK: - Typealias
    typealias Item = QuestItem
    typealias Category = QuestStatus
    
    // MARK: - Published Properties
    @Published private(set) var viewStatus: ViewStatus = .loading
    @Published var currentCategory: Category = .default {
        didSet {
            Task { await loadDataIfNeeded() }
        }
    }
    @Published var showSelectMyRegionView = false
    
    @Published private var defaultQuestListByFilter: [QuestFilterType: [QuestItem]] = [:]
    @Published private var repeatQuestListByFilter: [RepeatType: [QuestFilterType: [QuestItem]]] = [:]
    @Published private var eventQuestListByFilter: [EventQuestFilterType: [QuestItem]] = [:]
    
    // MARK: - Computed Properties
    var currentItems: [QuestItem] {
        switch currentCategory {
        case .default:
            return defaultQuestListByFilter[questFilterState.selectedValue] ?? []
        case .repeat:
            return repeatQuestListByFilter[repeatFilterState.selectedValue]?[questFilterState.selectedValue] ?? []
        case .event:
            return eventQuestListByFilter[eventFilterState.selectedValue] ?? []
        }
    }
    
    // MARK: - Stored Properties
    let questFilterState: StaticFilterPickerState<QuestFilterType>
    let repeatFilterState: StaticFilterPickerState<RepeatType>
    let eventFilterState: StaticFilterPickerState<EventQuestFilterType>
    
    private let defaultPaginationManager = PaginationManager<Item>(size: 10, threshold: 2)
    private let repeatPaginationManager = PaginationManager<Item>(size: 10, threshold: 2)
    private let eventPaginationManager = PaginationManager<Item>(size: 10, threshold: 2)
    
    private let throttleInterval: TimeInterval = 2.0
    private var lastRefreshTime: Date?
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Dependencies
    private let questRepository: QuestRepositoryInterface
    private let favoriteService: FavoriteService
    private let illsangZoneManager: IllsangZoneManager
    private let questSubmissionNotifier: QuestSubmissionNotifier
    private let sharedState: SharedState
    
    init(
        questRepository: QuestRepositoryInterface,
        favoriteService: FavoriteService,
        illsangZoneManager: IllsangZoneManager,
        questSubmissionNotifier: QuestSubmissionNotifier,
        sharedState: SharedState
    ) {
        self.questRepository = questRepository
        self.favoriteService = favoriteService
        self.illsangZoneManager = illsangZoneManager
        self.questSubmissionNotifier = questSubmissionNotifier
        self.sharedState = sharedState
        
        self.questFilterState = StaticFilterPickerState<QuestFilterType>(initialValue: .popular)
        self.eventFilterState = StaticFilterPickerState<EventQuestFilterType>(initialValue: .popular)
        self.repeatFilterState = StaticFilterPickerState<RepeatType>(initialValue: .daily)
      
        setupFilterStateObserver()
        setupPaginationManagers()
        
        Task { await setupBindings() }
        Log("🍭 QuestViewModel: init")
    }
    
    deinit {
        cancellables.removeAll()
        Log("🍭 QuestViewModel: deinit")
    }
    
    private func setupFilterStateObserver() {
        questFilterState.onSelectionChange = { [weak self] _ in
            guard let self = self else { return }
            Task { await self.loadInitialData() }
        }
        eventFilterState.onSelectionChange = { [weak self] _ in
            guard let self = self else { return }
            Task { await self.loadInitialData() }
        }
        repeatFilterState.onSelectionChange = { [weak self] _ in
            guard let self = self else { return }
            Task { await self.loadInitialData() }
        }
    }
    
    private func setupPaginationManagers() {
        self.defaultPaginationManager.loadPageData = { [weak self] page, size in
            guard let self = self else { return true }
            return await self.loadPageData(page: page, size: size, category: .default)
        }
        self.repeatPaginationManager.loadPageData = { [weak self] page, size in
            guard let self = self else { return true }
            return await self.loadPageData(page: page, size: size, category: .repeat)
        }
        self.eventPaginationManager.loadPageData = { [weak self] page, size in
            guard let self = self else { return true }
            return await self.loadPageData(page: page, size: size, category: .event)
        }
    }
    
    @MainActor
    private func setupBindings() {
        sharedState.$selectedCommercialArea
            .removeDuplicates()
            .dropFirst()
            .sink { [weak self] _ in
                Task { await self?.loadAllInitialData() }
            }
            .store(in: &cancellables)
        
        // refreshTrigger가 변경될 때마다 데이터 갱신
        questSubmissionNotifier.$refreshTrigger
            .removeDuplicates()
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                Log("🏠 QuestViewModel: 퀘스트 제출 트리거 > 리프레시 예정")
                Task {
                    await self?.loadAllInitialData()
                }
            }
            .store(in: &cancellables)
    }
    
    func loadDataIfNeeded() async {
        if isCurrentListEmpty {
            await loadInitialDataWithLoadingState(for: currentCategory)
        }
    }
    
    private func loadInitialDataWithLoadingState(for category: Category) async {
        await changeViewStatus(.loading)
        let minimumDelay: UInt64 = 300_000_000 // 최소 응답 지연 시간 추가 (0.3초)
        async let dataLoad: Void = loadInitialData()
        async let delay: Void = Task.sleep(nanoseconds: minimumDelay)
        _ = try? await (dataLoad, delay)
        await changeViewStatus(.loaded)
    }
    
    private func loadAllInitialData() async {
        await changeViewStatus(.loading)
        async let defaultLoad: () = loadInitialData(for: .default)
        async let repeatLoad: () = loadInitialData(for: .repeat)
        async let eventLoad: () = loadInitialData(for: .event)
        _ = await (defaultLoad, repeatLoad, eventLoad)
        await changeViewStatus(.loaded)
    }
    
    func reloadData() async {
        // 마지막 새로고침으로부터 throttleInterval 이내에 새로 고침 시도를 방지
        let now = Date()
        
        if let lastRefreshTime = lastRefreshTime, now.timeIntervalSince(lastRefreshTime) < throttleInterval {
            return
        }
        lastRefreshTime = now
        await loadInitialData(for: currentCategory)
        lastRefreshTime = Date()
    }
    
    @MainActor
    func changeViewStatus(_ viewStatus: ViewStatus) {
        self.viewStatus = viewStatus
    }
    
    @MainActor
    func loadPageData(
        page: Int,
        size: Int,
        category: Category,
    ) async -> Bool {
        let getQuestList = await getQuestList(page: page, size: size, category: category)
        var newQuestList = getQuestList.data
        
        // 현재 필터별 existingList 가져오기
        let existingList: [Item]
        switch category {
        case .default:
            existingList = defaultQuestListByFilter[questFilterState.selectedValue] ?? []
        case .repeat:
            let rFilter = repeatFilterState.selectedValue
            let qFilter = questFilterState.selectedValue
            existingList = repeatQuestListByFilter[rFilter]?[qFilter] ?? []
        case .event:
            let filter = eventFilterState.selectedValue
            existingList = eventQuestListByFilter[filter] ?? []
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
        
        var mergedList: [QuestItem]
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
        switch category {
        case .default:
            let questFilter = questFilterState.selectedValue
            mapDefaultQuestByFilter(list: mergedList, filter: questFilter)
        case .repeat:
            mapRepeatQuestByFilter(list: mergedList, repeatType: repeatFilterState.selectedValue, filter: questFilterState.selectedValue)
        case .event:
            mapEventQuestByFilter(list: mergedList, filter: eventFilterState.selectedValue)
        }
        
        return getQuestList.isLast
    }
    
    /// uncompleted 상태의 기본 퀘스트 목록을 XpStat별로 분류하여 defaultQuestListByXpStat 딕셔너리에 매핑합니다.
    private func mapDefaultQuestByFilter(list: [Item], filter: QuestFilterType) {
        var mapped = defaultQuestListByFilter
        mapped[filter] = list
        self.defaultQuestListByFilter = mapped
    }
    
    private func mapRepeatQuestByFilter(list: [Item], repeatType: RepeatType, filter: QuestFilterType) {
        var mapped = repeatQuestListByFilter
        var subMapped = mapped[repeatType] ?? [:]
        subMapped[filter] = list
        mapped[repeatType] = subMapped
        self.repeatQuestListByFilter = mapped
    }
    
    private func mapEventQuestByFilter(list: [Item], filter: EventQuestFilterType) {
        var mapped = eventQuestListByFilter
        mapped[filter] = list
        self.eventQuestListByFilter = mapped
    }
    
    private func getQuestList(page: Int, size: Int, category: Category) async -> (data: [Item], isLast: Bool) {
        let myCommercialCode = await MainActor.run { illsangZoneManager.currentZoneCode }
        let selectedCommercialCode = sharedState.selectedCommercialArea.code
        let result: Result<ResponseWithPage<[Quest]>, Error>
        
        switch category {
        case .default:
            result = await questRepository.getDefaultQuests(
                commercialAreaCode: selectedCommercialCode,
                orderRewardDesc: questFilterState.selectedValue.orderRewardDesc,
                page: page,
                size: size
            )
        case .repeat:
            result = await questRepository.getRepeatQuests(
                commercialAreaCode: selectedCommercialCode,
                repeatFrequency: repeatFilterState.selectedValue,
                orderRewardDesc: questFilterState.selectedValue.orderRewardDesc,
                page: page,
                size: size
            )
        case .event:
            result = await questRepository.getEventQuests(
                commercialAreaCode: selectedCommercialCode,
                orderRewardDesc: eventFilterState.selectedValue.orderRewardDesc,
                orderExpiredDesc: eventFilterState.selectedValue.orderExpiredDesc,
                page: page,
                size: size
            )
        }
        
        switch result {
        case .success(let response):
            return (response.content.map { $0.toQuestItem(myCommercialCode: myCommercialCode, questCommercialCode: selectedCommercialCode) }, response.isLast)
        case .failure:
            return ([], true)
        }
    }
    
    func paginationManager(for category: Category) -> PaginationManager<QuestItem> {
        switch category {
        case .default: return defaultPaginationManager
        case .repeat: return repeatPaginationManager
        case .event: return eventPaginationManager
        }
    }
    
    func handleMyRegionSelection(_ area: CommercialArea) {
        sharedState.selectedCommercialArea = area
    }
    
    /// 즐겨찾기 상태를 UI에 즉시 반영하고,  서버 반영은 디바운싱 처리
    func toggleFavoriteStatus(quest: Item) {
        favoriteService.toggle(quest: quest)
    }
    
    func closeFilterPicker() {
        self.questFilterState.pickerStatus  = .close
        self.repeatFilterState.pickerStatus = .close
        self.eventFilterState.pickerStatus = .close
    }
}
