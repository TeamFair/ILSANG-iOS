//
//  QuestViewModel.swift
//  ILSANG
//
//  Created by Lee Jinhee on 5/23/24.
//

import UIKit

class QuestViewModel: ObservableObject {
    // TODO: API 요청 실패 시 에러상태로 변경하기
    enum ViewStatus {
        case error
        case loading
        case loaded
    }
    
    @Published var viewStatus: ViewStatus = .loading
    
    // TODO: 바뀔 때 api 요청하도록 수정 (refresh, init 고려)
    @Published var selectedHeader: QuestStatus = .default
    
    @Published var showSelectMyRegionView: Bool = false
    @Published var alertType: AlertType? = nil
    
    // 필터
    @Published var repeatFilterState: FilterPickerState<RepeatType>
    @Published var questFilterState: FilterPickerState<QuestFilterType>
    @Published var eventFilterState: FilterPickerState<EventQuestFilterType>

    // 선택된 퀘스트
    @Published var selectedQuest: QuestViewModelItem = .mockData
    @Published var showQuestSheet: Bool = false
    @Published var showSubmitRouterView: Bool = false {
        didSet {
            // TODO: 도전내역 등록 완료시 리스트에서 퀘스트만 삭제/추가하도록 개선(퀘스트 조회 API 호출x)
            if showSubmitRouterView == false {
                Task { await loadInitialData() }
            }
        }
    }
    @Published var showQuestEngageView: Bool = false {
        didSet {
            // TODO: 도전내역 등록 완료시 리스트에서 퀘스트만 삭제/추가하도록 개선(퀘스트 조회 API 호출x)
            if showQuestEngageView == false {
                Task { await loadInitialData() }
            }
        }
    }
    
    @Published var defaultQuestListByFilter: [QuestFilterType: [QuestViewModelItem]] = [:]
    @Published var repeatQuestListByFilter: [RepeatType: [QuestFilterType: [QuestViewModelItem]]] = [:]
    @Published var eventQuestListByFilter: [EventQuestFilterType: [QuestViewModelItem]] = [:]
    @Published var completedQuestList: [QuestViewModelItem] = []

    
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
    
    // TODO: 퀘스트 갯수 확인 필요
    // TODO: 현재 0페이지만 불러오며, 임시로 60개 로딩. 스탯 분류&필터링과 관련해서 기획 & API 수정에 따라 페이지네이션 로직 수정 필요
    lazy var defaultPaginationManager = PaginationManager<QuestViewModelItem>(
        size: 60,
        threshold: 58,
        loadPage: { [weak self] page in
            guard let self = self else { return ([], 0) }
            return await loadQuestListWithImage(page: page, size: 60, status: .default)
        }
    )
    
    // TODO: 현재 0페이지만 불러오며, 임시로 40개 로딩. 스탯 분류&필터링과 관련해서 기획 & API 수정에 따라 페이지네이션 로직 수정 필요
    lazy var repeatPaginationManager = PaginationManager<QuestViewModelItem>(
        size: 40,
        threshold: 38,
        loadPage: { [weak self] page in
            guard let self = self else { return ([], 0) }
            return await loadQuestListWithImage(page: page, size: 40, status: .repeat)
        }
    )
    
    // TODO: 스탯 분류&필터링과 관련해서 기획 & API 수정에 따라 페이지네이션 로직 수정 필요
    lazy var eventPaginationManager = PaginationManager<QuestViewModelItem>(
        size: 30,
        threshold: 28,
        loadPage: { [weak self] page in
            guard let self = self else { return ([], 0) }
            return await loadQuestListWithImage(page: page, size: 30, status: .event)
        }
    )
    
    lazy var completedPaginationManager = PaginationManager<QuestViewModelItem>(
        size: 10,
        threshold: 8,
        loadPage: { [weak self] page in
            guard let self = self else { return ([], 0) }
            return await loadQuestListWithImage(page: page, size: 10, status: .completed)
        }
    )
    
    // MARK: throttle 관련
    let throttleInterval: TimeInterval = 2.0
    var lastRefreshTime: Date? = nil
    
    private let questRepository: QuestRepositoryInterface
    private let favoriteService: FavoriteService
    let sharedState: SharedState
    
    init(questRepository: QuestRepositoryInterface, favoriteService: FavoriteService, sharedState: SharedState) {
        self.questRepository = questRepository
        self.favoriteService = favoriteService
        
        // 필터 설정
        questFilterState = FilterPickerState(initialValue: QuestFilterType.popular)
        eventFilterState = FilterPickerState(initialValue: EventQuestFilterType.popular)
        repeatFilterState = FilterPickerState(initialValue: RepeatType.daily)
                
        self.sharedState = sharedState

        questFilterState.onSelectionChange = { [weak self] _ in
            guard let self = self else { return }
            Task { await self.defaultPaginationManager.loadData(isRefreshing: true) }
        }
        eventFilterState.onSelectionChange = { [weak self] _ in
            guard let self = self else { return }
            Task { await self.eventPaginationManager.loadData(isRefreshing: true) }
        }
        repeatFilterState.onSelectionChange = { [weak self] _ in
            guard let self = self else { return }
            Task { await self.repeatPaginationManager.loadData(isRefreshing: true) }
        }
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
            switch questFilterState.selectedValue {
            case .pointHighest:
                result = await questRepository.getDefaultQuests(commercialAreaCode: sharedState.selectedCommercialArea.code, orderRewardDesc: false, page: page, size: size)
            case .pointLowest:
                result = await questRepository.getDefaultQuests(commercialAreaCode: sharedState.selectedCommercialArea.code, orderRewardDesc: true, page: page, size: size)
            case .popular:
                result = await questRepository.getDefaultQuests(commercialAreaCode: sharedState.selectedCommercialArea.code, orderRewardDesc: nil, page: page, size: size)
            }
        case .repeat:
            switch questFilterState.selectedValue {
            case .pointHighest:
                result = await questRepository.getRepeatQuests(
                    commercialAreaCode: sharedState.selectedCommercialArea.code,
                    repeatFrequency: self.repeatFilterState.selectedValue,
                    orderRewardDesc: false,
                    page: page,
                    size: size
                )
            case .pointLowest:
                result = await questRepository.getRepeatQuests(
                    commercialAreaCode: sharedState.selectedCommercialArea.code,
                    repeatFrequency: self.repeatFilterState.selectedValue,
                    orderRewardDesc: true,
                    page: page,
                    size: size
                )
            case .popular:
                result = await questRepository.getRepeatQuests(
                    commercialAreaCode: sharedState.selectedCommercialArea.code,
                    repeatFrequency: self.repeatFilterState.selectedValue,
                    orderRewardDesc: nil,
                    page: page,
                    size: size
                )
            }
        case .event:
            switch eventFilterState.selectedValue {
            case .pointHighest:
                result = await questRepository.getEventQuests(commercialAreaCode: sharedState.selectedCommercialArea.code, orderRewardDesc: false, page: page, size: size)
            case .pointLowest:
                result = await questRepository.getEventQuests(commercialAreaCode: sharedState.selectedCommercialArea.code, orderRewardDesc: true, page: page, size: size)
            case .popular, .upcoming:
                result = await questRepository.getEventQuests(commercialAreaCode: sharedState.selectedCommercialArea.code, orderRewardDesc: nil, page: page, size: size)
            }
        case .completed:
            result = await questRepository.getCompletedQuests(commercialAreaCode: sharedState.selectedCommercialArea.code, page: page, size: size)
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
    
    func onQuestTapped(quest: QuestViewModelItem) {
        AnalyticsService.logEvent(.questItemClick(questId: quest.id, questType: quest.questType?.rawValue.uppercased() ?? ""))
        selectedQuest = quest
        Task {
            let questDetail = try await questRepository.getQuestDetail(questId: quest.id)
                .get()
                .toQuestItem()
            self.selectedQuest = questDetail
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
            self.showQuestSheet = true
        }
    }
    
    func handleMyRegionSelection(_ area: CommercialArea) {
        sharedState.selectedCommercialArea = area
        self.alertType = .myRegionChangeSuccess
        Task { await self.loadInitialData() }
    }
    
    
    /// 즐겨찾기 상태를 UI에 즉시 반영하고,  서버 반영은 디바운싱 처리
    func toggleFavoriteStatus(quest: QuestViewModelItem) {
        favoriteService.toggle(quest: quest)
    }
    
    func onQuestApprovalTapped() {
        showQuestSheet = false
        if selectedQuest.missionType == .photo {
            showSubmitRouterView = true
        } else {
            showQuestEngageView = true
        }
    }
    
    func closeFilterPicker() {
        self.questFilterState.pickerStatus  = .close
        self.repeatFilterState.pickerStatus = .close
        self.eventFilterState.pickerStatus = .close
    }
}
