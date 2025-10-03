//
//  HomeViewModel.swift
//  ILSANG
//
//  Created by Lee Jinhee on 12/28/24.
//

import UIKit
import Combine

enum ViewStatus {
    case error
    case loading
    case loaded
}

final class HomeViewModel: ObservableObject {
    @Published var viewStatus: ViewStatus = .loading
    @Published var userProfileImage: UIImage?
    var recommendQuestTitle: String {
        if let nickname = UserService.shared.currentUser?.nickname {
            return nickname + "님을 위한 추천 퀘스트"
        } else {
            return "추천 퀘스트"
        }
    }
    @Published var mainBanners: [BannerViewModelItem] = []
    @Published var userRankList: [UserRankViewModelItem] = [] // 10개
    @Published var largestRewardQuestList: [QuestViewModelItem] = [] // 3*5개
    @Published var recommendQuestList: [QuestViewModelItem] = [] //QuestViewModelItem.mockQuestList // 10개
    @Published var popularQuestList: [QuestViewModelItem] = [] // 4n개
    
    @Published var currentBanner: Int = 0
    
    @Published var selectedPopularTabIndex: Int = 0
    let popularChunkSize: Int = 4
    var paginatedPopularQuests: [[QuestViewModelItem]] {
        popularQuestList.chunks(of: popularChunkSize)
    }
    
    @Published var showSelectMyRegionView: Bool = false
    @Published var selectedBanner: BannerViewModelItem? = nil
        
    var errorCnt = 0
    @Published var showMainBanners: Bool = true
    @Published var showLargestRewardQuest: Bool = true
    @Published var showRecommendQuest: Bool = true
    @Published var showPopularQuest: Bool = true
    @Published var showRankList = true
    
    private var loadTask: Task<Void, Never>? = nil
    
    private let userRepository: UserRepositoryInterface
    private let areaNameService: AreaNameProvider
    private let questRepository: QuestRepositoryInterface
    private let rankRepository: RankRepositoryInterface
    private let bannerRepository: BannerRepositoryInterface
    private let favoriteService: FavoriteService
    private let questSubmissionNotifier: QuestSubmissionNotifier
    private let sharedState: SharedState
    
    private var cancellables = Set<AnyCancellable>()
    
    init(
        userRepository: UserRepositoryInterface,
        areaNameService: AreaNameProvider,
        questRepository: QuestRepositoryInterface,
        rankRepository: RankRepositoryInterface,
        bannerRepository: BannerRepositoryInterface,
        favoriteService: FavoriteService,
        questSubmissionNotifier: QuestSubmissionNotifier,
        sharedState: SharedState
    )  {
        self.userRepository = userRepository
        self.areaNameService = areaNameService
        self.questRepository = questRepository
        self.rankRepository = rankRepository
        self.bannerRepository = bannerRepository
        self.favoriteService = favoriteService
        self.questSubmissionNotifier = questSubmissionNotifier
        self.sharedState = sharedState
        
        Task { await setupBindings() }
        Log("🏠 HomeViewModel: init")
    }
    
    deinit {
        Log("🏠 HomeViewModel: deinit")
        self.cancellables.removeAll()
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
        
        // 퀘스트 수행 후 데이터 갱신
        questSubmissionNotifier.$refreshTrigger
            .removeDuplicates()
            .dropFirst()
            .sink { [weak self] _ in
                Log("🏠 HomeViewModel: 퀘스트 제출 트리거 > 리프레시 예정")
                Task {
                    await self?.loadInitialDataSafe()
                }
            }
            .store(in: &cancellables)
    }
    
    @MainActor
    func loadDataIfNeeded() async {
        if mainBanners.isEmpty ||
            popularQuestList.isEmpty ||
            recommendQuestList.isEmpty ||
            largestRewardQuestList.isEmpty ||
            userRankList.isEmpty {
            await loadInitialData()
        }
    }
    
    func loadInitialDataSafe() async {
        loadTask?.cancel()
        loadTask = Task {
            await loadInitialData()
        }
        await loadTask?.value
    }
    
    @MainActor
    func loadInitialData() async {
        self.errorCnt = 0
        changeViewStatus(.loading)
        self.showMainBanners = true
        self.showPopularQuest = true
        self.showRecommendQuest = true
        self.showLargestRewardQuest = true
        self.showRankList = true
        
        await withThrowingTaskGroup(of: Void.self) { group in
            group.addTask {
                do {
                    try await self.loadMainBanners()
                } catch {
                    Log("Failed to load banners: \(error.localizedDescription)")
                    self.errorCnt += 1
                    self.showMainBanners = false
                }
            }
            group.addTask {
                do {
                    try await self.loadPopularQuestList()
                    if self.popularQuestList.count < self.popularChunkSize {
                        await MainActor.run {
                            self.showPopularQuest = false
                        }
                    }
                } catch {
                    Log("Failed to load popular quests: \(error.localizedDescription)")
                    self.errorCnt += 1
                    self.showPopularQuest = false
                }
            }
            group.addTask {
                do {
                    try await self.loadRecommendQuestList()
                    if self.recommendQuestList.isEmpty {
                        await MainActor.run {
                            self.showRecommendQuest = false
                        }
                    }
                } catch {
                    Log("Failed to load recommend quests: \(error.localizedDescription)")
                    self.errorCnt += 1
                    self.showRecommendQuest = false
                }
            }
            group.addTask {
                do {
                    try await self.loadLargeRewardQuestList()
                    if self.largestRewardQuestList.isEmpty {
                        await MainActor.run {
                            self.showLargestRewardQuest = false
                        }
                    }
                } catch {
                    Log("Failed to load large reward quests: \(error.localizedDescription)")
                    self.errorCnt += 1
                    self.showLargestRewardQuest = false
                }
            }
            
            group.addTask {
                do {
                    try await self.loadRankList()
                    if self.userRankList.isEmpty {
                        await MainActor.run {
                            self.showRankList = false
                        }
                    }
                } catch {
                    Log("Failed to load large reward quests: \(error.localizedDescription)")
                    
                    self.errorCnt += 1
                    self.showRankList = false
                }
            }
        }
        
        if errorCnt >= 3 {
            changeViewStatus(.error)
            return
        }
        
        if let userProfileImageId = UserService.shared.currentUser?.profileImageId {
            self.userProfileImage = await ImageCacheService.shared.loadImageAsync(imageId: userProfileImageId)
        }
        
        changeViewStatus(.loaded)
    }
    
    @MainActor
    func loadMainBanners() async throws {
        let res = await bannerRepository.getBanner()
        
        switch res {
        case .success(let res):
            let updatedBanners = res.map { $0.toBanner() }
            
            // 비동기 이미지 로드 처리
            await withTaskGroup(of: Void.self) { group in
                for (index, banner) in updatedBanners.enumerated() {
                    group.addTask {
                        let image = await ImageCacheService.shared.loadImageAsync(imageId: banner.imageId)
                        updatedBanners[index].image = image
                    }
                }
            }
            
            // 업데이트된 배너 리스트를 mainBanners에 설정
            self.mainBanners = updatedBanners
            
            // 배너가 없으면 영역을 보여주지 않음
            if mainBanners.count == 0 {
                self.showMainBanners = false
            }
        case .failure(let error):
            throw error
        }
    }
    
    @MainActor
    func loadPopularQuestList() async throws {
        let res = await questRepository.getPopularQuests(commercialAreaCode: sharedState.selectedCommercialArea.code, page: 0, size: 8)
        
        switch res {
        case .success(let response):
            self.popularQuestList = response.content.map { $0.toQuestItem() }
            await cacheImages(for: &popularQuestList, getMainImage: true)
        case .failure(let error):
            throw error
        }
    }
    
    @MainActor
    func loadRecommendQuestList() async throws {
        let res = await questRepository.getRecommendQuests(commercialAreaCode: sharedState.selectedCommercialArea.code, page: 0, size: 10)
        
        switch res {
        case .success(let response):
            self.recommendQuestList = response.content.map { $0.toQuestItem() }
            await cacheImages(for: &recommendQuestList, getWriterImage: true)
        case .failure(let error):
            throw error
        }
    }
    
    @MainActor
    func loadLargeRewardQuestList() async throws {
        let res = await questRepository.getLargeRewardQuests(commercialAreaCode: sharedState.selectedCommercialArea.code, page: 0, size: 3)
        
        switch res {
        case .success(let quests):
            self.largestRewardQuestList = quests.content.map { $0.toQuestItem() }
            await cacheImages(for: &largestRewardQuestList, getWriterImage: true)
        case .failure(let error):
            throw error
        }
    }
    
    @MainActor
    func loadRankList() async throws {
        let res = await rankRepository.getTotalUserRank(commercialAreaCode: sharedState.selectedCommercialArea.code)
        
        switch res {
        case .success(let rank):
            self.userRankList = rank.map { $0.toRankItem() }
            // TODO: 유틸 함수로 만들기
            await withTaskGroup(of: (Int, UIImage?).self) { group in
                for (index, rank) in userRankList.enumerated() {
                    group.addTask {
                        guard let imageId = rank.profileImageId else { return (index, nil) }
                        let image = await ImageCacheService.shared.loadImageAsync(imageId: imageId)
                        return (index, image)
                    }
                }
                
                /// UI 업데이트
                for await (index, image) in group {
                    await MainActor.run {
                        self.userRankList[index].profileImage = image
                    }
                }
            }
            
        case .failure(let error):
            throw error
        }
    }
    
    /// getWriterImage, getMainImage 중 가져올 이미지 타입을 true로 설정
    @MainActor
    func cacheImages(for quests: inout [QuestViewModelItem], getWriterImage: Bool = false, getMainImage: Bool = false) async {
        await withTaskGroup(of: (Int, UIImage?).self) { group in
            for (index, quest) in quests.enumerated() {
                group.addTask {
                    let imageId: String
                    if getWriterImage {
                        guard let writerImageId = quest.imageId else { return (index, nil) }
                        imageId = writerImageId
                    } else if getMainImage {
                        guard let mainImageId = quest.mainImageId else { return (index, nil) }
                        imageId = mainImageId
                    } else {
                        fatalError("getWriterImage, getMainImage 중 하나의 값은 true이어야 함")
                    }
                    let image = await ImageCacheService.shared.loadImageAsync(imageId: imageId)
                    return (index, image)
                }
            }
            
            for await (index, image) in group {
                if let image {
                    if getWriterImage {
                        quests[index].image = image
                    }
                    if getMainImage {
                        quests[index].mainImage = image
                    }
                }
            }
        }
    }
    
    // 메인 배너에서 사용되는 화면 이동 처리
    func getTabFromURL(from urlString: String) -> Tab? {
        guard let (host, path) = extractHostAndPath(urlString), host == "tab", let path = path else {
            print("Invalid or unsupported URL.")
            return nil
        }
        
        if let tab = Tab(rawValue: path) {
            return tab
        } else {
            print("Tab not found or unsupported: \(path)")
            return nil
        }
        
    }
    
    private func extractHostAndPath(_ urlString: String) -> (String?, String?)? {
        // "tab"과 "quest or home or ..." 추출
        guard let url = URL(string: urlString), let host = url.host else { return nil }
        
        // path의 첫 번째 "/" 제거
        let path = url.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        return (host, path)
    }
    
    
    @MainActor
    func changeViewStatus(_ viewStatus: ViewStatus) {
        self.viewStatus = viewStatus
    }
    
    // 내 지역 선택 완료 시
    func handleMyRegionSelection(_ area: CommercialArea) {
        sharedState.selectedCommercialArea = area
    }
    
    /// 즐겨찾기 상태를 UI에 즉시 반영하고,  서버 반영은 디바운싱 처리
    func toggleFavoriteStatus(quest: QuestViewModelItem) {
        favoriteService.toggle(quest: quest)
    }
}
