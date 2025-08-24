//
//  HomeViewModel.swift
//  ILSANG
//
//  Created by Lee Jinhee on 12/28/24.
//

import UIKit

enum ViewStatus {
    case error
    case loading
    case loaded
}

@Observable
final class HomeViewModel {
    var viewStatus: ViewStatus = .loading
    var userProfileImage: UIImage?
    var recommendQuestTitle: String {
        if let nickname = UserService.shared.currentUser?.nickname {
            return nickname + "님을 위한 추천 퀘스트"
        } else {
            return "추천 퀘스트"
        }
    }
    var mainBanners: [Banner] = []
    var userRankList: [TopRankViewModelItem] = [] // 10개
    var largestRewardQuestList: [QuestViewModelItem] = [] // 3*5개
    var recommendQuestList: [QuestViewModelItem] = [] //QuestViewModelItem.mockQuestList // 10개
    var popularQuestList: [QuestViewModelItem] = [QuestViewModelItem.mockData] // 4n개
    
    var currentBanner: Int = 0
    
    var showQuestSheet: Bool = false
    var selectedQuest: QuestViewModelItem = .mockData
    var selectedPopularTabIndex: Int = 0
    let popularChunkSize: Int = 4
    var paginatedPopularQuests: [[QuestViewModelItem]] {
        popularQuestList.chunks(of: popularChunkSize)
    }
    var showSubmitRouterView: Bool = false {
        didSet {
            // TODO: 해당 데이터가 포함되어있으면 제거 or 리로드하도록 수정
            if showSubmitRouterView == false {
                Task {
                    await loadInitialData()
                }
            }
        }
    }
    var showQuestEngageView: Bool = false {
        didSet {
            // TODO: 해당 데이터가 포함되어있으면 제거 or 리로드하도록 수정
            if showSubmitRouterView == false {
                Task {
                    await loadInitialData()
                }
            }
        }
    }
    var showSelectMyRegionView: Bool = false
    var showSelectIllsangZoneView: Bool = false
    var selectedBanner: Banner? = nil
    
    var illsangZoneCode: String? = nil
    var illsangZoneName: String? = nil
    var alertType: AlertType? = nil
    
    var isNeverShowAlertSelected: Bool = false // 일상존미선택 알럿 - 토글버튼
    var isQuestSheetPending: Bool = false // 퀘스트 시트를 다시 열어야 하는지 여부
    
    var shouldShowIllsangZoneWarning: Bool = false
    
    private let dontShowKey = "DontShowIllsangZoneWarning"
    private let seasonKey = "IllsangZoneSeason"
    
    let currentSeason: Int = 1 // TODO: 서버에서 가져오도록 수정
    
    // 다른 유저 프로필 확인
    var showOtherUserProfileView = false
    var selectedCustomerId: String? = nil
    
    var errorCnt = 0
    var showMainBanners: Bool = true
    var showLargestRewardQuest: Bool = true
    var showRecommendRewardQuest: Bool = true
    var showPopularRewardQuest: Bool = true
    var showRankList = true
    
    private let questRepository: QuestRepositoryInterface
    private let rankNetwork: RankNetwork
    private let bannerNetwork: BannerNetwork
    private let favoriteService: FavoriteService
    private let sharedState: SharedState

    init(questRepository: QuestRepositoryInterface, rankNetwork: RankNetwork, bannerNetwork: BannerNetwork, favoriteService: FavoriteService, sharedState: SharedState) {
        self.questRepository = questRepository
        self.rankNetwork = rankNetwork
        self.bannerNetwork = bannerNetwork
        self.favoriteService = favoriteService
        self.sharedState = sharedState
        
        Task {
            await loadInitialData()
        }
    }
    
    @MainActor
    func loadInitialData() async {
        self.errorCnt = 0
        changeViewStatus(.loading)
        self.showMainBanners = true
        self.showPopularRewardQuest = true
        self.showRecommendRewardQuest = true
        self.showLargestRewardQuest = true
        self.showRankList = true
        updateIllsangZoneWarningStatus()

        await withThrowingTaskGroup(of: Void.self) { group in
//            group.addTask {
//                do {
//                    try await self.loadMainBanners()
//                } catch {
//                    Log("Failed to load banners: \(error.localizedDescription)")
//                    self.errorCnt += 1
//                    self.showMainBanners = false
//                }
//            }
            group.addTask {
                do {
                    try await self.loadPopularQuestList()
                } catch {
                    Log("Failed to load popular quests: \(error.localizedDescription)")
                    self.errorCnt += 1
                    self.showPopularRewardQuest = false
                }
            }
            group.addTask {
                do {
                    try await self.loadRecommendQuestList()
                } catch {
                    Log("Failed to load recommend quests: \(error.localizedDescription)")
                    self.errorCnt += 1
                    self.showRecommendRewardQuest = false
                }
            }
            group.addTask {
                do {
                    try await self.loadLargeRewardQuestList()
                } catch {
                    Log("Failed to load large reward quests: \(error.localizedDescription)")
                    self.errorCnt += 1
                    self.showLargestRewardQuest = false
                }
            }
            
            group.addTask {
                do {
                    try await self.loadRankList()
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
        let res = await bannerNetwork.getMainBanners()
        
        switch res {
        case .success(let res):
            // 활성화된 배너만 필터링 및 매핑
            var updatedBanners = res.content.filter { $0.activeYn == "Y" }.map { Banner(from: $0) }
            
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
        let res = await rankNetwork.getTopUserRank()
        
        switch res {
        case .success(let rank):
            self.userRankList = rank.data.map({ TopRankViewModelItem(rank: $0) })
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
                if let image = image {
                    quests[index].image = image
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
    
    func onQuestTapped(quest: QuestViewModelItem) {
        selectedQuest = quest
        Task {
            let questDetail = try await questRepository.getQuestDetail(questId: quest.id)
                .get()
                .toQuestItem()
            self.selectedQuest = questDetail
        }
        
        if illsangZoneCode == nil && shouldShowIllsangZoneWarning {
            isQuestSheetPending = true // 일상존 선택 후 다시 열기 위해 기록
            alertType = .illsangZoneNotSelected
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.showQuestSheet.toggle()
            }
        }
    }
    
    func onQuestApprovalTapped() {
        showQuestSheet = false
        if selectedQuest.missionType == .photo {
            showSubmitRouterView = true
        } else {
            showQuestEngageView = true
        }
    }
    
    // 일상존 선택 완료 시
    func handleIllsangZoneSelection(_ area: CommercialArea) {
        self.illsangZoneCode = area.code
        self.illsangZoneName = area.areaName
        self.alertType = .illsangZoneSetSuccess
    }
    
    // TODO: 함수명 변경
    func finalizeIllsangZoneSelection() {
        alertType = nil
        if isQuestSheetPending {
            isQuestSheetPending = false
            showQuestSheet = true
        }
    }
    
    // 내 지역 선택 완료 시
    func handleMyRegionSelection(_ area: CommercialArea) {
        sharedState.selectedCommercialArea = area
        self.alertType = .myRegionChangeSuccess
        Task { await self.loadInitialData() }
        // TODO: 배너 제외 데이터 재로드
    }
    
    /// "다시 보지 않기" 체크 여부 확인
    private func updateIllsangZoneWarningStatus() {
        let savedSeason = UserDefaults.standard.integer(forKey: seasonKey)
        let dontShow = UserDefaults.standard.bool(forKey: dontShowKey)
        
        // 시즌이 바뀌었거나 "다시 보지 않기" 안 한 경우엔 보여주기
        if savedSeason != currentSeason || !dontShow {
            shouldShowIllsangZoneWarning = true
        }
    }
    
    /// "다시 보지 않기" 선택 시 저장
    func saveDontShowPreferenceIfSelected() {
        if isNeverShowAlertSelected {
            UserDefaults.standard.set(true, forKey: dontShowKey)
            UserDefaults.standard.set(currentSeason, forKey: seasonKey)
            shouldShowIllsangZoneWarning = false
        }
    }
    
    /// 즐겨찾기 상태를 UI에 즉시 반영하고,  서버 반영은 디바운싱 처리
    func toggleFavoriteStatus(quest: QuestViewModelItem) {
        favoriteService.toggle(quest: quest)
    }
}

struct TopRankViewModelItem {
    let customerId: String
    let lank: Int
    let xpSum: Int
    let nickname: String
    let profileImageId: String?
    var profileImage: UIImage?
    
    init(customerId: String, lank: Int, xpSum: Int, nickname: String, profileImageId: String?, profileImage: UIImage?) {
        self.customerId = customerId
        self.lank = lank
        self.xpSum = xpSum
        self.nickname = nickname
        self.profileImageId = profileImageId
        self.profileImage = profileImage
    }
    
    init(rank: TopRank) {
        self.customerId = rank.customerId
        self.lank = rank.lank
        self.xpSum = rank.xpSum
        self.nickname = rank.nickname
        self.profileImageId = rank.profileImageId
        self.profileImage = nil
    }
}
