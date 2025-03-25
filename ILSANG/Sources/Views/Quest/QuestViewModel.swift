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
    @Published var selectedXpStat: XpStat

    // 필터
    @Published var repeatFilterState: FilterPickerState<RepeatType>
    @Published var questFilterState: FilterPickerState<QuestFilterType>

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
    
    @Published var itemListByStatus: [QuestStatus: [QuestViewModelItem]] = [
        .default: [],
        .repeat: [],
        .completed: []
    ]
    
    var defaultQuestListByXpStat: [XpStat: [QuestViewModelItem]] = Dictionary(uniqueKeysWithValues: XpStat.allCases.map { ($0, []) })
    var repeatQuestListByXpStat: [XpStat: [QuestViewModelItem]] = Dictionary(uniqueKeysWithValues: XpStat.allCases.map { ($0, []) })

    var filteredDefaultQuestListByXpStat: [QuestViewModelItem] {
        switch questFilterState.selectedValue {
        case .pointHighest:
            return defaultQuestListByXpStat[selectedXpStat, default: []].sorted { $0.rewardDic[selectedXpStat, default: 0] > $1.rewardDic[selectedXpStat, default: 0] }
        case .pointLowest:
            return defaultQuestListByXpStat[selectedXpStat, default: []].sorted { $0.rewardDic[selectedXpStat, default: 0] < $1.rewardDic[selectedXpStat, default: 0] }
        case .popular:
            return defaultQuestListByXpStat[selectedXpStat, default: []]
        }
    }
    
    var filteredRepeatQuestListByXpStat: [QuestViewModelItem] {
        switch questFilterState.selectedValue  {
        case .pointHighest:
            return repeatQuestListByXpStat[selectedXpStat, default: []].sorted { $0.rewardDic[selectedXpStat, default: 0] > $1.rewardDic[selectedXpStat, default: 0] }
        case .pointLowest:
            return repeatQuestListByXpStat[selectedXpStat, default: []].sorted { $0.rewardDic[selectedXpStat, default: 0] < $1.rewardDic[selectedXpStat, default: 0] }
        case .popular:
            return repeatQuestListByXpStat[selectedXpStat, default: []]
        }
    }
    
    var isCurrentListEmpty: Bool {
        switch selectedHeader {
        case .default:
            return itemListByStatus[.default, default: []].isEmpty || filteredDefaultQuestListByXpStat.isEmpty
        case .repeat:
            return itemListByStatus[.repeat, default: []].isEmpty || filteredRepeatQuestListByXpStat.isEmpty
        case .completed:
            return itemListByStatus[.completed, default: []].isEmpty
        }
    }
    // TODO: 퀘스트 갯수 확인 필요
    // TODO: 현재 0페이지만 불러오며, 임시로 80개 로딩. 스탯 분류&필터링과 관련해서 기획 & API 수정에 따라 페이지네이션 로직 수정 필요
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
    
    private let questNetwork: QuestNetwork
    
    init(questNetwork: QuestNetwork, selectedXpStat: XpStat) {
        self.selectedXpStat = selectedXpStat
        self.questNetwork = questNetwork
        
        // 필터 설정
        questFilterState = FilterPickerState(initialValue: QuestFilterType.popular)
        repeatFilterState = FilterPickerState(initialValue: RepeatType.daily)
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
        async let completedLoad: () = completedPaginationManager.loadData(isRefreshing: true)
        _ = await (defaultLoad, repeatLoad, completedLoad)
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
    func loadQuestListWithImage(page: Int, size: Int, status: QuestStatus) async -> ([QuestViewModelItem], Int) {
        let getQuestList = await getQuestList(page: page, size: size, status: status)
        
        var newQuestList = getQuestList.data
        var currentQuestList = itemListByStatus[status, default: []]
        
        // 중복된 항목 제거 로직
        let currentQuestIds = Set(currentQuestList.map { $0.id }) // 현재 리스트의 ID 집합 (page 1이상일 경우만 고려됨)
        var seenIds = Set<String>() // 추가될 퀘스트에서 확인된 ID를 저장할 집합
        
        newQuestList = newQuestList.filter { quest in
            // ID가 집합에 없으면 true를 반환하고, 집합에 추가
            if seenIds.contains(quest.id) || (currentQuestIds.contains(quest.id) && page > 0) {
                return false
            } else {
                seenIds.insert(quest.id)
                return true
            }
        }
        
        if page == 0 {
            currentQuestList = newQuestList
        } else {
            currentQuestList += newQuestList
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
                        currentQuestList[index].image = image
                    } else {
                        currentQuestList[currentQuestList.count - newQuestList.count + index].image = image
                    }
                }
            }
        }
        itemListByStatus[status] = currentQuestList
        
        if status == .default {
            mapDefaultQuestByXpStat()
        } else if status == .repeat {
            mapRepeatQuestByXpStat()
        }
        return (itemListByStatus[status, default: []], getQuestList.total)
    }
    
    /// uncompleted 상태의 기본 퀘스트 목록을 XpStat별로 분류하여 defaultQuestListByXpStat 딕셔너리에 매핑합니다.
    private func mapDefaultQuestByXpStat() {
        guard let uncompletedQuestList = itemListByStatus[.default] else { return }
        self.defaultQuestListByXpStat = self.defaultQuestListByXpStat.mapValues { _ in [] } // 초기화
        
        for item in uncompletedQuestList {
            for reward in item.rewardDic {
                defaultQuestListByXpStat[reward.key]?.append(item)
            }
        }
    }
    
    private func mapRepeatQuestByXpStat() {
        guard let repeatQuestList = itemListByStatus[.repeat] else { return }
        self.repeatQuestListByXpStat = self.repeatQuestListByXpStat.mapValues { _ in [] } // 초기화
        
        for item in repeatQuestList {
            for reward in item.rewardDic {
                repeatQuestListByXpStat[reward.key]?.append(item)
            }
        }
    }
    
    private func getQuestList(page: Int, size: Int, status: QuestStatus) async -> (data: [QuestViewModelItem], total: Int) {
        let result: Result<ResponseWithPage<[Quest]>, Error>
        
        switch status {
        case .default:
            result = await questNetwork.getDefaultQuest(page: page, size: size)
        case .repeat:
            result = await questNetwork.getRepeatQuest(status: self.repeatFilterState.selectedValue, page: page, size: size)
        case .completed:
            result = await questNetwork.getCompletedQuest(page: page, size: size)
        }
        
        switch result {
        case .success(let response):
            return (response.data.map { QuestViewModelItem(quest: $0) }, response.total)
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
        case .completed:
            return completedPaginationManager.canLoadMoreData()
        }
    }
    
    func onQuestTapped(quest: QuestViewModelItem) {
        AnalyticsService.logEvent(.questItemClick(questId: quest.id, questType: quest.type.uppercased()))
        selectedQuest = quest
        showQuestSheet = true
    }
    
    func onQuestApprovalTapped() {
        showQuestSheet = false
        if selectedQuest.missionType == .image {
            showSubmitRouterView = true
        } else {
            showQuestEngageView = true
        }
    }
    
    func closeFilterPicker() {
        self.questFilterState.pickerStatus  = .close
        self.repeatFilterState.pickerStatus = .close
    }
}
