//
//  ApprovalViewModel.swift
//  ILSANG
//
//  Created by Lee Jinhee on 6/1/24.
//

import UIKit
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

enum ApprovalSource: Equatable {
    case tab
    case detail(missionId: Int, quest: QuestItem)
}

final class ApprovalViewModel: ObservableObject, SinglePaginationLoadable {
    // MARK: - Typealias
    typealias Item = ApprovalMissionHistoryItem
    
    // MARK: - Published Properties
    @Published var viewStatus: ViewStatus = .loading
    @Published var currentItems: [ApprovalMissionHistoryItem] = []
    @Published var selectedChallenge: ApprovalMissionHistoryItem?
    @Published var showReportAlert = false

    // MARK: - Stored Properties
    let approvalSource: ApprovalSource
    
    internal let paginationManager = PaginationManager<ApprovalMissionHistoryItem>(size: 10, threshold: 2)
    
    private let emojiNetwork: EmojiNetwork
    private let missionHistoryRepository: MissionHistoryRepository
    private let areaNameService: AreaNameProvider
    
    init(
        approvalSource: ApprovalSource,
        emojiNetwork: EmojiNetwork,
        missionHistoryRepository: MissionHistoryRepository,
        areaNameService: AreaNameProvider
    ) {
        self.approvalSource = approvalSource
        self.emojiNetwork = emojiNetwork
        self.missionHistoryRepository = missionHistoryRepository
        self.areaNameService = areaNameService
        
        setupPaginationManagers()
        
        Log("✨ ApprovalViewModel: init")
    }
    
    deinit {
        Log("✨ ApprovalViewModel: deinit")
    }
    
    private func setupPaginationManagers() {
        self.paginationManager.loadPageData = { [weak self] page, size in
            guard let self else { return true }
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
        changeViewStatus(.loading)
        let minimumDelay: UInt64 = 300_000_000 // 최소 응답 지연 시간 추가 (0.3초)
        async let dataLoad: Void = loadInitialData()
        async let delay: Void = Task.sleep(nanoseconds: minimumDelay)
        _ = try? await (dataLoad, delay)
        await self.paginationManager.loadData(isRefreshing: true)
        changeViewStatus(.loaded)
    }
    
    // MARK: - 도전내역 랜덤 조회
    /// 페이지 번호를 받아 해당 페이지의 도전 내역 데이터를 로드 및 가공
    @MainActor
    func loadPageData(page: Int, size: Int) async -> Bool {
        // 1. 챌린지 데이터 로드
        let (challenges, isLast) = await loadChallenges(page: page)
        
        // 2. 중복 제거
        let filteredChallenges = removeDuplicateChallenges(challenges)
        
        // 3. 이미지 병합
        let enrichedChallenges = await enrichChallengesWithImage(filteredChallenges)
        
        // 4. 지역 코드 → 지역명 매핑
        let mappedChallenges = await mapAreaNames(for: enrichedChallenges)
        
        // 5. itemList 업데이트
        updateItemList(for: page, with: mappedChallenges)
        
        return isLast
    }
    
    // MARK: 도전내역 조회 - Helper Methods
    /// 1. 챌린지 데이터 로드
    private func loadChallenges(page: Int) async -> ([ApprovalMissionHistoryItem], Bool) {
        switch approvalSource {
        case .tab:
            let result = await getRandomChallenges(page: page, size: paginationManager.size)
            return (result.data, result.isLast)
        case .detail(let missionId, let quest):
            let result = await getChallenges(missionId: missionId, page: page, size: paginationManager.size, quest: quest)
            return (result.data, result.isLast)
        }
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
            currentItems = challenges
        } else {
            currentItems += challenges
        }
    }
    
    /// like 버튼을 눌렀을 때 호출됩니다.
    func onLike(for idx: Int) {
        Task {
            await updateEmoji(emojiType: .like, idx: idx)
        }
    }
    
    @MainActor
    private func updateEmoji(emojiType: EmojiType, idx: Int) async {
        let item = currentItems[idx]
        
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
        
        item.likeCount = newCount(item.likeCount, isSelected: item.emojis.isSelected(.like))
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
    private func getRandomChallenges(page: Int, size: Int) async -> (data: [ApprovalMissionHistoryItem], isLast: Bool) {
        let res = await missionHistoryRepository.getRandomMissionHistories(page: page, size: size)
        switch res {
        case .success(let response):
            return (response.data.map {$0.toApprovalItem()}, response.isLast)
        case .failure(let err):
            Log("도전내역랜덤 조회 실패 \(err.localizedDescription)")
            return ([], true)
        }
    }
    
    private func getChallenges(missionId: Int, page: Int, size: Int, quest: QuestItem) async -> (data: [ApprovalMissionHistoryItem], isLast: Bool) {
        let res = await missionHistoryRepository.getMissionHistories(missionId: missionId, page: page, size: size)
        switch res {
        case .success(let response):
            return (response.data.map {$0.toApprovalItem(quest: quest)}, response.isLast)
        case .failure(let err):
            Log("미션 \(missionId) 도전내역 조회 실패 \(err.localizedDescription)")
            return ([], true)
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
