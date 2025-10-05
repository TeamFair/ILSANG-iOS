//
//  MissionHistoryViewModel.swift
//  ILSANG
//
//  Created by Lee Jinhee on 8/28/25.
//


import SwiftUI

final class UserMissionHistoryViewModel: ObservableObject {
    @Published var missionHistories: [UserMissionHistoryItem] = []
    
    @Published var challengeDelete = false
    
    var hasMorePage: Bool {
        challengePaginationManager.canLoadMoreData()
    }
    
    let missionHistoryRepository: MissionHistoryRepository
    
    init(missionHistoryRepository: MissionHistoryRepository, challengeDelete: Bool = false) {
        self.missionHistoryRepository = missionHistoryRepository
        challengePaginationManager.loadPageData = { [weak self] page in
            guard let self = self else { return ([], 0) }
            return await loadChallengeListWithImage(page: page, size: 10)
        }
    }
    
    var challengePaginationManager = PaginationManager<UserMissionHistoryItem>(
        size: 10,
        threshold: 7
    )
    
    @discardableResult @MainActor
    func loadChallengeListWithImage(page: Int, size: Int) async -> ([UserMissionHistoryItem], Int) {
        let getChallengeList = await fetchChallenges(page: page, size: size)
        let newChallengeList = getChallengeList.data
        
        if page == 0 {
            self.missionHistories = newChallengeList
        } else {
            self.missionHistories += newChallengeList
        }
        
        await withTaskGroup(of: (Int, UIImage?).self) { group in
            for (index, challenge) in newChallengeList.enumerated() {
                group.addTask {
                    let imageId = challenge.submitImageId
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
                        self.missionHistories[index].submitImage = image
                    } else {
                        self.missionHistories[missionHistories.count - newChallengeList.count + index].submitImage = image
                    }
                }
            }
        }
        
        return (missionHistories, getChallengeList.total)
    }
    
    private func fetchChallenges(page: Int, size: Int) async -> (data: [UserMissionHistoryItem], total: Int) {
        let response = await missionHistoryRepository.getMissionHistories(page: page, size: size, userId: nil)
        
        switch response {
        case .success(let res):
            // 데이터 초기화: 이미지가 없는 상태로 미리 표시
            return (res.data.map { $0.toItem() }, res.total)
        case .failure(let error):
            Log("챌린지 조회 실패: \(error)")
            return ([], 0)
        }
    }
    
    
    func deleteMissionHistory(id: Int) async -> Bool {
        return await missionHistoryRepository.deleteMissionHistory(missionHistoryId: id)
    }
    
    func getImage(imageId: String) async -> UIImage? {
        await ImageCacheService.shared.loadImageAsync(imageId: imageId)
    }
    
    
}
