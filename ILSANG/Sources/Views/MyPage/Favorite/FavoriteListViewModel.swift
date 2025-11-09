//
//  FavoriteListViewModel.swift
//  ILLSANG
//
//  Created by Lee Jinhee on 9/6/25.
//

import Combine
import UIKit

class FavoriteListViewModel: ObservableObject, SinglePaginationLoadable {
    // MARK: - Typealias
    typealias Item = QuestItem
    
    // MARK: - Published Properties
    @Published private(set) var viewStatus: ViewStatus = .loading
    @Published private(set) var currentItems: [Item] = []
    @Published private(set) var selectedArea: CommercialArea
    @Published var showSelectRegionView: Bool = false
    
    // MARK: - Stored Properties
    internal let paginationManager: PaginationManager<Item> = PaginationManager(size: 10, threshold: 2)
    
    private let questRepository: QuestRepositoryInterface
    private let favoriteService: FavoriteService
    private let illsangZoneManager: IllsangZoneManager
    private let questSubmissionNotifier: QuestSubmissionNotifier
    
    private var refreshTask: Task<Void, Never>?
    private var cancellables = Set<AnyCancellable>()
    
    init(
        questRepository: QuestRepositoryInterface,
        favoriteService: FavoriteService,
        illsangZoneManager: IllsangZoneManager,
        selectedCommercialArea: CommercialArea,
        questSubmissionNotifier: QuestSubmissionNotifier
    ) {
        self.questRepository = questRepository
        self.favoriteService = favoriteService
        self.illsangZoneManager = illsangZoneManager
        self.selectedArea = selectedCommercialArea
        self.questSubmissionNotifier = questSubmissionNotifier
        
        setupBindings()
        setupPaginationManagers()
        Log("🏠 FavoriteListViewModel: init")
    }
    
    deinit {
        Log("🏠 FavoriteListViewModel: deinit")
        refreshTask?.cancel()
        refreshTask = nil
        cancellables.removeAll()
    }
    
    private func setupBindings() {
        questSubmissionNotifier.$refreshTrigger
            .removeDuplicates()
            .dropFirst()
            .sink { [weak self] _ in
                Log("🏠 FavoriteListViewModel: 퀘스트 제출 트리거 > 리프레시 예정")
                Task {
                    await self?.loadInitialData()
                }
            }
            .store(in: &cancellables)
    }
    
    private func setupPaginationManagers() {
        self.paginationManager.loadPageData = { [weak self] page, size in
            guard let self = self else { return true }
            return await self.loadPageData(page: page, size: size)
        }
    }
    
    func loadDataIfNeeded() async {
        if isCurrentListEmpty {
            await loadInitialDataWithLoadingState()
        }
    }
    
    @MainActor
    func loadInitialDataWithLoadingState() async {
        refreshTask?.cancel()
        refreshTask = Task { [weak self] in
            guard let self else { return }
            changeViewStatus(.loading)
            let minimumDelay: UInt64 = 300_000_000 // 최소 응답 지연 시간 추가 (0.3초)
            async let dataLoad: Void = loadInitialData()
            async let delay: Void = Task.sleep(nanoseconds: minimumDelay)
            _ = try? await (dataLoad, delay)
            changeViewStatus(.loaded)
        }
        await refreshTask?.value
    }
    
    @MainActor
    func loadPageData(
        page: Int,
        size: Int
    ) async -> Bool {
        let getQuestList = await getQuestList(areaCode: selectedArea.code, page: page, size: size)
        let newQuestList = getQuestList.data
        let existingList = currentItems
        
        var mergedList: [Item]
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
        self.currentItems = mergedList
        return getQuestList.isLast
    }
    
    private func getQuestList(areaCode: String, page: Int, size: Int) async -> (data: [Item], isLast: Bool) {
        let myCommercialCode = await MainActor.run { illsangZoneManager.currentZoneCode }

        switch await questRepository.getFavoriteQuests(commercialAreaCode: areaCode, page: page, size: size) {
        case .success(let response):
            return (response.content.map { $0.toQuestItem(myCommercialCode: myCommercialCode, questCommercialCode: areaCode) }, response.isLast)
        case .failure:
            return ([], true)
        }
    }
    
    // 내 지역 선택 완료 시
    @MainActor
    func handleAreaSelection(_ area: CommercialArea) {
        self.selectedArea = area
        Task { await loadInitialData() }
    }
    
    /// 즐겨찾기 상태를 UI에 즉시 반영하고,  서버 반영은 디바운싱 처리
    func toggleFavoriteStatus(quest: Item) {
        favoriteService.toggle(quest: quest)
    }
    
    @MainActor
    func changeViewStatus(_ viewStatus: ViewStatus) {
        self.viewStatus = viewStatus
    }
}
