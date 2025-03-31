//
//  OtherUserProfileViewModel.swift
//  ILSANG
//
//  Created by Lee Jinhee on 3/8/25.
//

import Foundation
import UIKit

@MainActor
final class OtherUserProfileViewModel: ObservableObject {
    @Published var userData: User?
    @Published var userProfileIamge: UIImage?
    
    @Published var xpStats: [XpStat: Int] = [:]
    @Published var challengeList: [ChallengeViewModelItem] = []
    
    lazy var challengePaginationManager = PaginationManager<ChallengeViewModelItem>(
        size: 10,
        threshold: 7,
        loadPage: { [weak self] page in
            guard let self = self else { return ([], 0) }
            return await loadChallengeListWithImage(page: page, size: 10)
        }
    )
    
    let customerId: String
    private let userNetwork: UserNetwork
    private let challengeNetwork: ChallengeNetwork
    private let imageNetwork: ImageNetwork
    private let xpNetwork: XPNetwork
    
    var currentLv: Int {
        XpLevelCalculator.convertXPtoLv(xp: userData?.xpPoint)
    }
    var progress: Double {
        let levelData = XpLevelCalculator.xpProgressInCurrentLevel(xp: userData?.xpPoint ?? 0, level: currentLv)
        return XpLevelCalculator.calculateProgress(currentValue: levelData.currentLevelXP, totalValue: levelData.requiredXPForNextLevel)
    }
    
    init(customerId: String, userNetwork: UserNetwork, challengeNetwork: ChallengeNetwork, imageNetwork: ImageNetwork, xpNetwork: XPNetwork) {
        self.customerId = customerId
        
        self.userNetwork = userNetwork
        self.challengeNetwork = challengeNetwork
        self.imageNetwork = imageNetwork
        self.xpNetwork = xpNetwork
    }
    
    func loadInitialData() async {
        await fetchUser(customerId: customerId)
        await fetchXpStats(customerId: customerId)
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
        let response = await challengeNetwork.getChallenges(page: page, size: size, userId: customerId)
        
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
    func fetchUser(customerId: String) async {
        let res = await userNetwork.getUser(customerId: customerId)
        
        switch res {
        case .success(let model):
            self.userData = model.data
            self.userProfileIamge = await ImageCacheService.shared.loadImageAsync(imageId: model.data.profileImage ?? "")
        case .failure(let error):
            self.userData = nil
            Log("사용자 정보 조회 실패: \(error)")
        }
    }
    
    @MainActor
    func fetchXpStats(customerId: String) async {
        let res = await xpNetwork.getXpStats(customerId: customerId)
        
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
    
    func getImage(imageId: String) async -> UIImage? {
        await ImageCacheService.shared.loadImageAsync(imageId: imageId)
    }
    
    func hasMorePage() -> Bool {
        challengePaginationManager.canLoadMoreData()
    }
}
