//
//  MyPageViewModel.swift
//  ILSANG
//
//  Created by Kim Andrew on 6/25/24.
//

import UIKit

struct XpStatus {
    let currentXp: Int
    let currentLv: Int
    let remainXp: Int
    let progress: Double

    init(currentXp: Int) {
        self.currentXp = currentXp
        self.currentLv = XpLevelCalculator.convertXPtoLv(xp: currentXp)
        self.remainXp = XpLevelCalculator.xpForNextLv(xp: currentXp)
        
        let levelData = XpLevelCalculator.xpProgressInCurrentLevel(xp: currentXp, level: currentLv)
        self.progress = XpLevelCalculator.calculateProgress(
            currentValue: levelData.currentLevelXP,
            totalValue: levelData.requiredXPForNextLevel
        )
    }
}

@MainActor
final class MyPageViewModel: ObservableObject {
    @Published var userData: User?
    @Published var xpStatus: XpStatus = XpStatus(currentXp: 0)

    @Published var honorTitle: String? = ""
    @Published var honorType: HonorGrade?
    @Published var userProfileImage: UIImage?
    
    @Published var selectedTab: MyPageTab = .quest
    
    @Published var points: [PointType: Int] = [:]
    @Published var challengeList: [ChallengeViewModelItem] = []
    
    @Published var challengeDelete = false
    
    lazy var challengePaginationManager = PaginationManager<ChallengeViewModelItem>(
        size: 10,
        threshold: 7,
        loadPage: { [weak self] page in
            guard let self = self else { return ([], 0) }
            return await loadChallengeListWithImage(page: page, size: 10)
        }
    )
    
    private let userNetwork: UserNetwork
    private let challengeNetwork: ChallengeNetwork
    private let imageNetwork: ImageNetwork
    private let pointNetwork: PointNetwork
    
    init(userNetwork: UserNetwork, challengeNetwork: ChallengeNetwork, imageNetwork: ImageNetwork, pointNetwork: PointNetwork) {
        self.userNetwork = userNetwork
        self.challengeNetwork = challengeNetwork
        self.imageNetwork = imageNetwork
        self.pointNetwork = pointNetwork
        
        self.userData = UserService.shared.currentUser
        self.xpStatus = XpStatus(currentXp: userData?.xpPoint ?? 0)
    }
    
    @MainActor
    func loadDataIfNeeded() async {
        if challengeList.isEmpty {
            await loadInitialData()
        }
    }
    
    func loadInitialData() async {
        // TODO: 도전내역 등록했을 때 재호출하도록 수정
        await challengePaginationManager.loadData(isRefreshing: true)
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
                    var image: UIImage? = nil
                    if let imageId {
                        image = await ImageCacheService.shared.loadImageAsync(imageId: imageId)
                    }
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
    
    @MainActor
    func fetchUser() async {
        let res = await userNetwork.getUser()
        
        switch res {
        case .success(let model):
            self.userData = model.data
            if let profileImage = userData?.profileImage {
                self.userProfileImage = await getImage(imageId: profileImage) /// 프로필 이미지 불러오기
            } else {
                self.userProfileImage = nil
            }
            self.honorTitle = userData?.title?.name
            self.honorType = HonorGrade(rawValue: userData?.title?.type ?? "")
            UserService.shared.currentUser = model.data
        case .failure(let err):
            self.userData = nil
            Log(err)
        }
    }
    
    @MainActor
    func fetchXpStats() async {
        let res = await pointNetwork.getPoints()
        
        switch res {
        case .success(let model):
            self.points = [
                .metro: model.data.metro,
                .commercial: model.data.commercial,
                .contribution: model.data.contribution
            ]
        case .failure(let error):
            Log("포인트 조회 실패: \(error)")
        }
    }
    
    func updateChallengeStatus(challengeId: String, imageId: String?) async -> Bool {
        var deleteImageRes = true  // 기본값 설정
        if let imageId {
            deleteImageRes = await imageNetwork.deleteImage(imageId: imageId)
        }
        let deleteChallengeRes = await challengeNetwork.deleteChallenge(challengeId: challengeId)
        
        return deleteChallengeRes && deleteImageRes
    }
    
    func getImage(imageId: String) async -> UIImage? {
        await ImageCacheService.shared.loadImageAsync(imageId: imageId)
    }
    
    func hasMorePage(for type: PaginationDataType) -> Bool {
        switch type {
        case .challenge:
            return challengePaginationManager.canLoadMoreData()
       }
    }
    
    enum PaginationDataType {
        case challenge
    }
}
