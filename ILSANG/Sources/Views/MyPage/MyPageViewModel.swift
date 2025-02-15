//
//  MyPageViewModel.swift
//  ILSANG
//
//  Created by Kim Andrew on 6/25/24.
//

import UIKit

@MainActor
final class MyPageViewModel: ObservableObject {
    @Published var userData: User?
    @Published var selectedTab: MyPageTab = .quest
    
    @Published var xpStats: [XpStat: Int] = [:]
    @Published var challengeList: [ChallengeViewModelItem] = []
    @Published var xpLogList: [XpLog] = []
    
    @Published var challengeDelete = false
    
    lazy var challengePaginationManager = PaginationManager<ChallengeViewModelItem>(
        size: 10,
        threshold: 7,
        loadPage: { [weak self] page in
            guard let self = self else { return ([], 0) }
            return await loadChallengeListWithImage(page: page, size: 10)
        }
    )
    
    lazy var xpLogPaginationManager = PaginationManager<XpLog>(
        size: 10,
        threshold: 7,
        loadPage: { [weak self] page in
            guard let self = self else { return ([], 0) }
            return await loadXpLogList(page: page, size: 10)
        }
    )
    
    private let userNetwork: UserNetwork
    private let challengeNetwork: ChallengeNetwork
    private let imageNetwork: ImageNetwork
    private let xpNetwork: XPNetwork
    
    init(userNetwork: UserNetwork, challengeNetwork: ChallengeNetwork, imageNetwork: ImageNetwork, xpNetwork: XPNetwork) {
        self.userNetwork = userNetwork
        self.challengeNetwork = challengeNetwork
        self.imageNetwork = imageNetwork
        self.xpNetwork = xpNetwork
        
        self.userData = UserService.shared.currentUser
        
        Task {
            await loadInitialData()
        }
    }
    
    func loadInitialData() async {
        // TODO: 도전내역 등록했을 때 재호출하도록 수정
        await challengePaginationManager.loadData(isRefreshing: true)
        await xpLogPaginationManager.loadData(isRefreshing: true)
    }
    
    @discardableResult @MainActor
    func loadChallengeListWithImage(page: Int, size: Int) async -> ([ChallengeViewModelItem], Int) {
        let getChallengeList = await fetchChallenges(page: page, size: size)
        let newChallengeList = getChallengeList.data
        
        if page == 0 {
            self.challengeList = newChallengeList
        } else {
            self.challengeList += newChallengeList
        }
        
        await withTaskGroup(of: (Int, UIImage?).self) { group in
            for (index, challenge) in newChallengeList.enumerated() {
                group.addTask {
                    let imageId = challenge.challengeImageId
                    let image = await ImageCacheService.shared.loadImageAsync(imageId: imageId)
                    return (index, image)
                }
            }
            
            for await (index, image) in group {
                if let image = image {
                    if page == 0 {
                        self.challengeList[index].challengeImage = image
                    } else {
                        self.challengeList[challengeList.count - newChallengeList.count + index].challengeImage = image
                    }
                }
            }
        }
        
        return (challengeList, getChallengeList.total)
    }
    
    @discardableResult @MainActor
    func loadXpLogList(page: Int, size: Int) async -> ([XpLog], Int) {
        let getXpLogList = await fetchXpLog(page: page, size: size)
        
        if page == 0 {
            self.xpLogList = getXpLogList.data
        } else {
            self.xpLogList += getXpLogList.data
        }
        
        return (xpLogList, getXpLogList.total)
    }
    
    private func fetchChallenges(page: Int, size: Int) async -> (data: [ChallengeViewModelItem], total: Int) {
        let response = await challengeNetwork.getChallenges(page: page, size: size)
        
        switch response {
        case .success(let res):
            // 데이터 초기화: 이미지가 없는 상태로 미리 표시
            return (res.data.map {ChallengeViewModelItem.init(challenge: $0)}, res.total)
        case .failure(let error):
            Log("챌린지 조회 실패: \(error)")
            return ([], 0)
        }
    }
    
    private func fetchXpLog(page: Int, size: Int) async -> (data: [XpLog], total: Int) {
        let res = await xpNetwork.getXpHistory(page: page, size: size)
        
        switch res {
        case .success(let model):
            return (model.data, model.total)
        case .failure(let error):
            Log("XP 로그 조회 실패: \(error)")
            return ([], 0)
        }
    }
    
    @MainActor
    func fetchUser() async {
        let res = await userNetwork.getUser()
        
        switch res {
        case .success(let model):
            self.userData = model.data
        case .failure(let err):
            self.userData = nil
            Log(err)
        }
    }
    
    @MainActor
    func fetchXpStats() async {
        let res = await xpNetwork.getXpStats()
        
        switch res {
        case .success(let model):
            let xpData = model.data
            self.xpStats = [
                .strength: xpData.strengthStat,
                .intellect: xpData.intellectStat,
                .fun: xpData.funStat,
                .charm: xpData.charmStat,
                .sociability: xpData.sociabilityStat
            ]
        case .failure(let error):
            Log("XP 스탯 조회 실패: \(error)")
        }
    }
    
    func updateChallengeStatus(challengeId: String, imageId: String) async -> Bool {
        let deleteChallengeRes = await challengeNetwork.deleteChallenge(challengeId: challengeId)
        let deleteImageRes = await imageNetwork.deleteImage(imageId: imageId)
        
        return deleteChallengeRes && deleteImageRes
    }
    
    func getImage(imageId: String) async -> UIImage? {
        await ImageCacheService.shared.loadImageAsync(imageId: imageId)
    }
    
    func hasMorePage(for type: PaginationDataType) -> Bool {
        switch type {
        case .challenge:
            return challengePaginationManager.canLoadMoreData()
        case .xpLog:
            return xpLogPaginationManager.canLoadMoreData()
        }
    }
    
    enum PaginationDataType {
        case challenge
        case xpLog
    }
}
