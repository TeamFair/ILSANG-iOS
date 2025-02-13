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
    @Published var mainBanners: [Banner] = []
    @Published var userRankList: [TopRankViewModelItem] = [] // 10개
    @Published var largestRewardQuestList: [XpStat: [QuestViewModelItem]] = [:] // 3*5개
    @Published var recommendQuestList: [QuestViewModelItem] = [] //QuestViewModelItem.mockQuestList // 10개
    @Published var popularQuestList: [QuestViewModelItem] = QuestViewModelItem.mockQuestList // 4n개
    
    @Published var selectedXpStat: XpStat = .strength

    @Published var showQuestSheet: Bool = false
    @Published var selectedQuest: QuestViewModelItem = .mockData
    @Published var selectedPopularTabIndex: Int = 0
    let popularChunkSize: Int = 4
    var paginatedPopularQuests: [[QuestViewModelItem]] {
        popularQuestList.chunks(of: popularChunkSize)
    }
    @Published var showQuestEngageView: Bool = false
    @Published var showSubmitRouterView: Bool = false {
        didSet {
            // TODO: 해당 섹션 데이터만 다시 불러오도록 수정
            if showSubmitRouterView == false {
                Task {
                    await loadInitialData()
                }
            }
        }
    }
    var errorCnt = 0
    @Published var showMainBanners: Bool = true
    @Published var showLargestRewardQuest: Bool = true
    @Published var showRecommendRewardQuest: Bool = true
    @Published var showPopularRewardQuest: Bool = true
    @Published var showRankList = true
    
    private let questNetwork: QuestNetwork
    private let rankNetwork: RankNetwork
    private let bannerNetwork: BannerNetwork
    
    init(questNetwork: QuestNetwork, rankNetwork: RankNetwork, bannerNetwork: BannerNetwork) {
        self.questNetwork = questNetwork
        self.rankNetwork = rankNetwork
        self.bannerNetwork = bannerNetwork
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
            // changeViewStatus(.error) // v1.3.0 이후 적용
            // return
            try? await loadUncompleteQuestList()
            self.showRecommendRewardQuest = true
            self.showPopularRewardQuest = true
        }

        if let userProfileImage = UserService.shared.currentUser?.profileImage {
            self.userProfileImage = await ImageCacheService.shared.loadImageAsync(imageId: userProfileImage)
        }

        changeViewStatus(.loaded)
    }
    
    @MainActor
    func loadMainBanners() async throws {
        let res = await bannerNetwork.getMainBanners()
        
        switch res {
        case .success(let res):
            // 활성화된 배너만 필터링 및 매핑
            var updatedBanners = res.data.filter { $0.activeYn == "Y" }.map { Banner(from: $0) }
            
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
        let res = await questNetwork.getPopularQuest()
        
        switch res {
        case .success(let response):
            self.popularQuestList = response.data.map { QuestViewModelItem(quest: $0) }
            await cacheImages(for: &popularQuestList, getMainImage: true)
        case .failure(let error):
            throw error
        }
    }
    
    @MainActor
    func loadRecommendQuestList() async throws {
        let res = await questNetwork.getUncompletedTotalQuest()
        
        switch res {
        case .success(let response):
            self.recommendQuestList = response.data.map { QuestViewModelItem(quest: $0) }
            await cacheImages(for: &recommendQuestList, getWriterImage: true)
        case .failure(let error):
            throw error
        }
    }
    
    @MainActor
    func loadLargeRewardQuestList() async throws {
        let res = await questNetwork.getLargeRewardQuestsByAllXpStats()
        
        switch res {
        case .success(let questByStat):
            for (stat, quests) in questByStat {
                self.largestRewardQuestList[stat] = quests.map { QuestViewModelItem(quest: $0) }
                await cacheImages(for: &largestRewardQuestList[stat, default: []], getWriterImage: true)
            }
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
    
    @MainActor
    func loadUncompleteQuestList() async throws {
        let res = await questNetwork.getDefaultQuest(page: 0, size: 20)
        
        switch res {
        case .success(let response):
            if response.data.count >= 9 {
                self.popularQuestList = Array(response.data.map { QuestViewModelItem(quest: $0) }[0..<9])
                await cacheImages(for: &popularQuestList, getWriterImage: true)
            }
            if response.data.count >= 20 {
                self.recommendQuestList = Array(response.data.map { QuestViewModelItem(quest: $0) }[10..<20])
                await cacheImages(for: &recommendQuestList, getWriterImage: true)
            }
        case .failure(let error):
            self.changeViewStatus(.error) // v1.3.0 이후 제거
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
        showQuestSheet.toggle()
    }
    
    func onQuestApprovalTapped() {
        showQuestSheet = false
        if selectedQuest.approvalType == .image { // TODO: 사진/ox 구분
            showSubmitRouterView = true
        } else {
            showQuestEngageView = true
        }
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
