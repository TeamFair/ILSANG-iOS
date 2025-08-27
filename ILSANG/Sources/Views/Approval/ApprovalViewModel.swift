//
//  ApprovalViewModel.swift
//  ILSANG
//
//  Created by Lee Jinhee on 6/1/24.
//

import SwiftUI
/*
✅ 이모지 에셋 변경
✅ 이모지 불러오기(idx 0, 1..<)
✅ 이모지 활성&비활성
✅ 이모지 카운트 +-
✅ 공유하기 & 신고하기 UI 추가
✅ 공유하기 & 신고하기 기능 추가
✅ 페이지네이션
✅ 리프레시
*/

@Observable
final class ApprovalViewModel {
    enum ViewStatus {
        case error
        case loading
        case loaded
    }
    
    var viewStatus: ViewStatus = .loading
    var itemList: [ApprovalMissionHistoryItem] = []
    
    var showReportAlert = false
    var selectedChallenge: ApprovalMissionHistoryItem?
    
    var paginationManager: PaginationManager<ApprovalMissionHistoryItem>?
    
    private let emojiNetwork: EmojiNetwork
    private let missionHistoryRepository: MissionHistoryRepository

    private let areaNameService: AreaNameProvider

    init(emojiNetwork: EmojiNetwork, missionHistoryRepository: MissionHistoryRepository, areaNameService: AreaNameProvider) {
        self.emojiNetwork = emojiNetwork
        self.missionHistoryRepository = missionHistoryRepository
        self.areaNameService = areaNameService
        
        self.paginationManager = PaginationManager<ApprovalMissionHistoryItem>(
            size: 10,
            threshold: 3,
            loadPage: { [weak self] page in
                guard let self = self else { return ([], 0) }
                return await self.getChallengesWithImage(page: page)
            }
        )
    }
    
    @MainActor
    func loadDataIfNeeded() async {
        if itemList.isEmpty {
            await loadInitialData()
        }
    }
    
    @MainActor
    func loadInitialData() async {
        changeViewStatus(.loading)
        await self.paginationManager?.loadData(isRefreshing: true)
        changeViewStatus(.loaded)
    }
    
    @MainActor
    func loadMoreData() async {
        guard ((paginationManager?.canLoadMoreData()) != nil) else { return }
        await paginationManager?.loadData(isRefreshing: false)
    }
        
    // MARK: - 도전내역 랜덤 조회
    /// 페이지 번호를 받아 해당 페이지의 도전 내역 데이터를 로드 및 가공
    @MainActor
    func getChallengesWithImage(page: Int) async -> ([ApprovalMissionHistoryItem], Int) {
        // 1. 챌린지 데이터 로드
        let (challenges, total) = await loadChallenges(page: page)
        
        // 2. 중복 제거
        let filteredChallenges = removeDuplicateChallenges(challenges)
        
        // 3. 이미지 병합
        let enrichedChallenges = await enrichChallengesWithImage(filteredChallenges)
        
        // 4. 지역 코드 → 지역명 매핑
        let mappedChallenges = await mapAreaNames(for: enrichedChallenges)
        
        // 5. itemList 업데이트
        updateItemList(for: page, with: mappedChallenges)
        
        return (itemList, total)
    }

    // MARK: 도전내역 조회 - Helper Methods
    /// 1. 챌린지 데이터 로드
    private func loadChallenges(page: Int) async -> ([ApprovalMissionHistoryItem], Int) {
        let result = await getRandomChallenges(page: page, size: paginationManager?.size ?? 10)
        return (result.data, result.total)
    }

    /// 2. 중복 제거: 동일한 ID를 가진 챌린지를 필터링하여 중복 제거
    private func removeDuplicateChallenges(_ challenges: [ApprovalMissionHistoryItem]) -> [ApprovalMissionHistoryItem] {
        var seenIDs = Set<Int>()
        return challenges.filter { challenge in
            if seenIDs.contains(challenge.id) {
                return false
            } else {
                seenIDs.insert(challenge.id)
                return true
            }
        }
    }

    /// 3. 이미지 병합: 각 챌린지에 이미지 정보를 추가
    private func enrichChallengesWithImage(
        _ challenges: [ApprovalMissionHistoryItem]
    ) async -> [ApprovalMissionHistoryItem] {
        return await withTaskGroup(of: (Int, UIImage?, UIImage?).self) { group in
            for (index, challenge) in challenges.enumerated() {
                group.addTask {
                    async let challengeImage = ImageCacheService.shared.loadImageAsync(imageId: challenge.imageId)
                    async let profileImage: UIImage? = {
                        guard let profileImageId = challenge.profileImageId else { return nil }
                        return await ImageCacheService.shared.loadImageAsync(imageId: profileImageId)
                    }()
                    
                    return (index, await challengeImage, await profileImage)
                }
            }
            
            let enrichedChallenges = challenges
            for await (index, challengeImage, profileImage) in group {
                if let challengeImage = challengeImage {
                    enrichedChallenges[index].image = challengeImage
                }
                if let profileImage = profileImage {
                    enrichedChallenges[index].profileImage = profileImage
                }
            }
            return enrichedChallenges
        }
    }

    /// 4. 지역 코드 → 지역명 매핑
    private func mapAreaNames(for challenges: [ApprovalMissionHistoryItem]) async -> [ApprovalMissionHistoryItem] {
        var results: [ApprovalMissionHistoryItem] = []
        
        for challenge in challenges {
            if let code = challenge.commercialAreaCode,
               let name = await areaNameService.getAreaName(for: code) {
                challenge.commercialAreaName = name
            }
            results.append(challenge)
        }
        return results

    }
    
    /// 5. itemList 업데이트
    @MainActor
    private func updateItemList(for page: Int, with challenges: [ApprovalMissionHistoryItem]) {
        if page == 0 {
            itemList = challenges
        } else {
            itemList += challenges
        }
    }
    
    /// like 버튼을 눌렀을 때 호출됩니다.
    func onLike(for idx: Int) {
        Task {
            await updateEmoji(emojiType: .like, idx: idx)
        }
    }
    
    /// hate 버튼을 눌렀을 때 호출됩니다.
    func onHate(for idx: Int) {
        Task {
            await updateEmoji(emojiType: .hate, idx: idx)
        }
    }
    
    @MainActor
    private func updateEmoji(emojiType: EmojiType, idx: Int) async {
        let item = itemList[idx]
        
        // 현재 상태
        let wasSelected = item.emojis.isSelected(emojiType)
        
        // 서버 요청
        let success: Bool
        if wasSelected {
            success = await emojiNetwork.deleteEmoji(missionHistoryId: item.id, emojiType: emojiType)
        } else {
            success = await emojiNetwork.postEmoji(missionHistoryId: item.id, emojiType: emojiType)
        }
        
        guard success else { return } // 서버 업데이트 실패 시 종료
        
        // 로컬 상태 토글
        item.emojis.toggle(emojiType)
        
        // count 업데이트
        func newCount(_ current: Int, isSelected: Bool) -> Int {
            max(current + (isSelected ? 1 : -1), 0)
        }
        
        switch emojiType {
        case .like:
            item.likeCount = newCount(item.likeCount, isSelected: item.emojis.isSelected(.like))
        case .hate:
            item.hateCount = newCount(item.hateCount, isSelected: item.emojis.isSelected(.hate))
        }
        
        // 리스트 업데이트
        itemList[idx] = item
    }
    
    /// 신고 확인 버튼을 눌렀을 때 호출됩니다.
    /// 선택된 챌린지를 서버에 신고 요청한 후, 알림을 닫습니다.
    func confirmReport() async {
        guard let _ = selectedChallenge else { return }
        await reportChallenge()
        showReportAlert = false
    }
    
    /// 신고 알림을 취소합니다.
    func dismissReportAlert() {
        showReportAlert = false
    }
    
    /// 뷰 상태를 변경합니다.
    /// - Parameter viewStatus: 변경할 새로운 뷰 상태.
    @MainActor
    func changeViewStatus(_ viewStatus: ViewStatus) {
        self.viewStatus = viewStatus
    }
    
    // MARK: - API 호출부
    private func getRandomChallenges(page: Int, size: Int) async -> (data: [ApprovalMissionHistoryItem], total: Int) {
        let res = await missionHistoryRepository.getRandomMissionHistories(page: page, size: size)
        switch res {
        case .success(let response):
            return (response.data.map {$0.toApprovalItem()}, response.total)
        case .failure(let err):
            Log("도전내역랜덤 조회 실패 \(err.localizedDescription)")
            return ([], 0)
        }
    }
    
    private func reportChallenge() async {
        guard let missionHistoryId = self.selectedChallenge?.id else { return }
        let result = await missionHistoryRepository.putMissionHistory(missionHistoryId: missionHistoryId)
        switch result {
        case .success:
            await loadInitialData() // TODO: 해당 챌린지를 목록에서 지우기
        case .failure(let err):
            Log("도전내역 신고 실패 \(missionHistoryId) \(err.localizedDescription)")
        }
    }
}
