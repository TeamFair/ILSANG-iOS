//
//  FavoriteListViewModel.swift
//  ILLSANG
//
//  Created by Lee Jinhee on 9/6/25.
//

import UIKit

class FavoriteListViewModel: ObservableObject {
    @Published var viewStatus: ViewStatus = .loading
    @Published var showSelectRegionView: Bool = false
    @Published var selectedArea: CommercialArea?
    @Published var quests: [QuestViewModelItem] = []
    
    // TODO: 페이지네이션 수정 필요
    let paginationManager: PaginationManager<QuestViewModelItem>
    
    private let questRepository: QuestRepositoryInterface
    private let favoriteService: FavoriteService
    
    private var refreshTask: Task<Void, Never>?
    
    init(
        questRepository: QuestRepositoryInterface,
        favoriteService: FavoriteService,
        selectedCommercialArea: CommercialArea
    ) {
        self.questRepository = questRepository
        self.favoriteService = favoriteService
        self.selectedArea = selectedCommercialArea
        
        self.paginationManager = PaginationManager(size: 20, threshold: 18)
        self.paginationManager.loadPageData = { [weak self] page in
            guard let self = self else { return ([], 0) }
            guard let areaCode = selectedArea?.code else { return ([], 0) }
            return await self.loadQuestListWithImage(areaCode: areaCode, page: page, size: 20)
        }
    }
    
    func loadDataIfNeeded() async {
        if quests.isEmpty {
            await loadInitialData()
        }
    }
    
    @MainActor
    func loadInitialData() async {
        refreshTask?.cancel()
        refreshTask = Task {
            changeViewStatus(.loading)
            guard let areaCode = selectedArea?.code else { return }
            await loadQuestListWithImage(areaCode: areaCode, page: 0, size: 10)
            changeViewStatus(.loaded)
        }
        await refreshTask?.value
    }
    
    @discardableResult @MainActor
    func loadQuestListWithImage(
        areaCode: String,
        page: Int,
        size: Int
    ) async -> ([QuestViewModelItem], Int) {
        let getQuestList = await getQuestList(areaCode: areaCode, page: page, size: size)
        let newQuestList = getQuestList.data
        let existingList = quests
        
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
        self.quests = mergedList
        return (mergedList, getQuestList.total)
    }
    
    private func getQuestList(areaCode: String, page: Int, size: Int) async -> (data: [QuestViewModelItem], total: Int) {
        switch await questRepository.getFavoriteQuests(commercialAreaCode: areaCode, page: page, size: size) {
        case .success(let response):
            return (response.content.map { $0.toQuestItem() }, response.totalElements)
        case .failure:
            return ([], 0)
        }
    }
    
    // 내 지역 선택 완료 시
    @MainActor
    func handleAreaSelection(_ area: CommercialArea) {
        self.selectedArea = area
        Task { await loadInitialData() }
    }
    
    /// 즐겨찾기 상태를 UI에 즉시 반영하고,  서버 반영은 디바운싱 처리
    func toggleFavoriteStatus(quest: QuestViewModelItem) {
        favoriteService.toggle(quest: quest)
    }
    
    func loadMoreData() async {
        guard paginationManager.canLoadMoreData() else { return }
        await paginationManager.loadData(isRefreshing: false)
    }
    
    @MainActor
    func changeViewStatus(_ viewStatus: ViewStatus) {
        self.viewStatus = viewStatus
    }
    
    enum ViewStatus {
        case error
        case loading
        case loaded
    }
}
