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
    
    init(emojiNetwork: EmojiNetwork, missionHistoryRepository: MissionHistoryRepository) {
        self.emojiNetwork = emojiNetwork
        self.missionHistoryRepository = missionHistoryRepository
        
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
        
        // 3. 이미지 및 이모지 병합
        let enrichedChallenges = await enrichChallengesWithImageAndEmoji(filteredChallenges)
        
        // 4. itemList 업데이트
        updateItemList(for: page, with: enrichedChallenges)
        
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

    /// 3. 이미지 및 이모지 병합: 각 챌린지에 이미지와 이모지 정보를 추가
    private func enrichChallengesWithImageAndEmoji(
        _ challenges: [ApprovalMissionHistoryItem]
    ) async -> [ApprovalMissionHistoryItem] {
        return await withTaskGroup(of: (Int, UIImage?, UIImage?, Emoji?).self) { group in
            for (index, challenge) in challenges.enumerated() {
                group.addTask {
                    async let challengeImage = ImageCacheService.shared.loadImageAsync(imageId: challenge.imageId)
                    async let profileImage: UIImage? = {
                        guard let profileImageId = challenge.profileImageId else { return nil }
                        return await ImageCacheService.shared.loadImageAsync(imageId: profileImageId)
                    }()
                    async let emoji = self.getEmoji(missionHistoryId: challenge.id)
                    
                    return (index, await challengeImage, await profileImage, await emoji)
                }
            }
            
            var enrichedChallenges = challenges
            for await (index, challengeImage, profileImage, emoji) in group {
                if let challengeImage = challengeImage {
                    enrichedChallenges[index].image = challengeImage
                }
                if let profileImage = profileImage {
                    enrichedChallenges[index].profileImage = profileImage
                }
                if let emoji = emoji {
                    enrichedChallenges[index].emoji = emoji
                }
            }
            return enrichedChallenges
        }
    }

    /// 4. itemList 업데이트
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
            await updateEmojiWithPrev(emojiType: .like, idx: idx)
        }
    }
    
    /// hate 버튼을 눌렀을 때 호출됩니다.
    func onHate(for idx: Int) {
        Task {
            await updateEmojiWithPrev(emojiType: .hate, idx: idx)
        }
    }
    
    /// 이모지 상태를 업데이트합니다.
    /// - 업데이트할 이모지 상태에 따라 서버에 요청을 보내고, 성공 시 로컬 상태를 변경합니다.
    /// - Parameters:
    ///   - emojiType: 업데이트할 이모지의 유형 (like 또는 hate).
    ///   - idx: 업데이트할 항목의 인덱스.
    @MainActor
    private func updateEmojiWithPrev(emojiType: EmojiType, idx: Int) async {
        // 현재 항목의 이전 이모지 상태를 가져옵니다.
        guard let prevEmoji = self.itemList[idx].emoji else { return }
        
        let wasPrevEmojiActive: Bool
        var emojiId: String? = nil

        // 업데이트할 이모지 유형에 따라 이전 상태와 ID를 설정합니다.
        switch emojiType {
        case .like:
            wasPrevEmojiActive = prevEmoji.isLike
            if let prevLikeId = prevEmoji.likeId {
                emojiId = prevLikeId
            }
        case .hate:
            wasPrevEmojiActive = prevEmoji.isHate
            if let prevHateId = prevEmoji.hateId {
                emojiId = prevHateId
            }
        }
        
        // 서버에 상태 업데이트 요청을 보냅니다.
        let challengeId = itemList[idx].id
        let isServerUpdateSuccessful = await updateEmojiStatus(missionHistoryId: challengeId, emojiType: emojiType, emojiId: emojiId, prevEmojiActive: wasPrevEmojiActive, idx: idx)
        
        // 서버 업데이트 성공 시 로컬 상태를 반영합니다.
        if isServerUpdateSuccessful {
            switch emojiType {
            case .like:
                self.itemList[idx].emoji?.isLike.toggle()
                if let emoji = self.itemList[idx].emoji, !emoji.isLike {
                    self.itemList[idx].emoji?.likeId = nil
                    self.itemList[idx].likeCount -= 1
                    self.itemList[idx].likeCount = max(self.itemList[idx].likeCount, 0)
                } else {
                    self.itemList[idx].likeCount += 1
                }
            case .hate:
                self.itemList[idx].emoji?.isHate.toggle()
                if let emoji = self.itemList[idx].emoji, !emoji.isHate {
                    self.itemList[idx].emoji?.hateId = nil
                    self.itemList[idx].hateCount -= 1
                    self.itemList[idx].hateCount = max(self.itemList[idx].hateCount, 0)
                } else {
                    self.itemList[idx].hateCount += 1
                }
            }
        }
    }
    
    /// 서버에 이모지 상태를 업데이트합니다.
    /// - 서버 상태를 변경하고, 성공하면 로컬 데이터를 수정합니다.
    /// - Parameters:
    ///   - challengeId: 이모지를 업데이트할 도전 ID.
    ///   - emojiType: 이모지의 유형 (like 또는 hate).
    ///   - emojiId: 삭제할 이모지의 ID. nil이면 새로 생성.
    ///   - prevEmojiActive: 이전 이모지가 활성화되어 있었는지 여부.
    ///   - idx: 업데이트할 항목의 인덱스.
    /// - Returns: 서버 업데이트 성공 여부를 반환합니다.
    @MainActor
    private func updateEmojiStatus(missionHistoryId: Int, emojiType: EmojiType, emojiId: String?, prevEmojiActive: Bool, idx: Int) async -> Bool {
        var updateSucceeded = false
        if prevEmojiActive {
            // 이전 이모지가 활성화 상태라면, 삭제 요청을 보냅니다.
            guard let emojiId = emojiId else { return false }
            updateSucceeded = await emojiNetwork.deleteEmoji(emojiId: emojiId)
        } else {
            // 이전 이모지가 비활성화 상태라면, 생성 요청을 보냅니다.
            let res = await emojiNetwork.postEmoji(missionHistoryId: missionHistoryId, emojiType: emojiType)
            switch res {
            case .success(let emojiId):
                // 서버로부터 받은 emojiId를 로컬 데이터에 저장합니다.
                switch emojiType {
                case .like:
                    self.itemList[idx].emoji?.likeId = emojiId
                case .hate:
                    self.itemList[idx].emoji?.hateId = emojiId
                }
                updateSucceeded = true
            case .failure:
                print(idx, missionHistoryId, "이모지 업데이트 상태 포스트 실패")
                updateSucceeded = false
            }
        }
        return updateSucceeded
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
    
    private func getEmoji(missionHistoryId: Int) async -> Emoji? {
        let getEmojiResult = await emojiNetwork.getEmoji(missionHistoryId: missionHistoryId)
        switch getEmojiResult {
        case .success(let response):
            return response.data
        case .failure(let err):
            Log("이모지 조회 실패 \(missionHistoryId) \(err.localizedDescription)")
            return nil
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
