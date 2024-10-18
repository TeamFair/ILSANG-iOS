//
//  ApprovalViewModel.swift
//  ILSANG
//
//  Created by Lee Jinhee on 6/1/24.
//

import SwiftUI

final class ApprovalViewModel: ObservableObject {
    // TODO: 페이지네이션 시 ViewStatus 고려 필요
    enum ViewStatus {
        case error
        case loading
        case loaded
    }
    
    @Published var viewStatus: ViewStatus = .loading
    @Published var itemList: [ApprovalViewModelItem] = []
    @Published var currentIdx = 0 {
        didSet {
            Task {
                await self.handleIndexChange(oldValue)
            }
        }
    }
    @Published var isScrolling = false
    @Published var emoji: Emoji?
    @Published var showReportAlert = false
    
    private lazy var paginationManager = PaginationManager<ApprovalViewModelItem>(
        size: 10,
        threshold: 3,
        loadPage: { [weak self] page in
            guard let self = self else { return ([], 0) }
            return await self.getChallengesWithImage(page: page)
        }
    )
    
    private let emojiNetwork: EmojiNetwork
    private let challengeNetwork: ChallengeNetwork
    
    init(emojiNetwork: EmojiNetwork, challengeNetwork: ChallengeNetwork) {
        self.emojiNetwork = emojiNetwork
        self.challengeNetwork = challengeNetwork
    }
    
    @MainActor
    func getData() async {
        changeViewStatus(.loading)
        await self.paginationManager.loadData(isRefreshing: true)

        self.currentIdx = 0
        if let challengeId = itemList.first?.id {
            await getEmoji(challengeId: challengeId)
        }
        changeViewStatus(.loaded)
    }
    
    @MainActor
    func changeViewStatus(_ viewStatus: ViewStatus) {
        self.viewStatus = viewStatus
    }
    
    @MainActor
    func handleIndexChange(_ previousIdx: Int) async {
        guard !itemList.isEmpty else { return }
        
        await getEmoji(challengeId: itemList[currentIdx].id)
        
        if previousIdx < currentIdx {
            if paginationManager.canLoadMoreData(index: currentIdx, currentCount: itemList.count) {
                await paginationManager.loadData(isRefreshing: false)
            }
        }
    }
    
    @MainActor
    func getChallengesWithImage(page: Int) async -> ([ApprovalViewModelItem], Int) {
        let getChallengeResult = await getRandomChallenges(page: page, size: paginationManager.size)
        var challenges = getChallengeResult.data
        
        // 중복된 id 제거
        var seenIDs = Set<String>()
        challenges = challenges.filter { challenge in
            if seenIDs.contains(challenge.id) {
                return false
            } else {
                seenIDs.insert(challenge.id)
                return true
            }
        }
        
        if page == 0 {
            itemList = challenges
        } else {
            itemList += challenges
        }
        
        await withTaskGroup(of: (Int, UIImage?).self) { group in
            for (index, challenge) in challenges.enumerated() {
                group.addTask {
                    let image = await ImageCacheService.shared.loadImageAsync(imageId: challenge.imageId)
                    return (index, image)
                }
            }
            
            for await (index, image) in group {
                if let image = image {
                    if page == 0 {
                        itemList[index].image = image
                    } else {
                        itemList[itemList.count - challenges.count + index].image = image
                    }
                }
            }
        }
        
        return (itemList, getChallengeResult.total)
    }
    
    private func getRandomChallenges(page: Int, size: Int) async -> (data: [ApprovalViewModelItem], total: Int) {
        let res = await challengeNetwork.getRandomChallenges(page: page, size: size)
        switch res {
        case .success(let response):
            return (response.data.map { ApprovalViewModelItem.init(challenge: $0) }, response.total)
        case .failure:
            return ([], 0)
        }
    }
    
    /// 업데이트할 이모지 타입에 따라 이전 이모지 상태의 반대로 서버에 업데이트를 요청하고,
    /// 서버 업데이트가 성공하면 로컬 상태를 업데이트합니다.
    /// - Parameter emojiType: 업데이트할 이모지의 유형 (like 또는 hate).
    @MainActor func updateEmojiWithPrev(emojiType: EmojiType) async {
        guard let prevEmoji = self.emoji else { return }
        
        let wasPrevEmojiActive: Bool
        var emojiId: String? = nil

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
        
        let challengeId = itemList[currentIdx].id
        let isServerUpdateSuccessful = await updateEmojiStatus(challengeId: challengeId, emojiType: emojiType, emojiId: emojiId, prevEmojiActive: wasPrevEmojiActive)
        
        if isServerUpdateSuccessful {
            switch emojiType {
            case .like:
                self.emoji?.isLike.toggle()
                if let emoji = self.emoji, !emoji.isLike {
                    self.emoji?.likeId = nil
                }
            case .hate:
                self.emoji?.isHate.toggle()
                if let emoji = self.emoji, !emoji.isHate {
                    self.emoji?.hateId = nil
                }
            }
        }
    }
    
    /// 이모지 등록하면 emojiid받아와서 현재 Emoji에 넣어줌
    @MainActor
    private func updateEmojiStatus(challengeId: String, emojiType: EmojiType, emojiId: String?, prevEmojiActive: Bool) async -> Bool {
        var updateSucceeded = false
        if prevEmojiActive {
            guard let emojiId = emojiId else { return false }
            updateSucceeded = await emojiNetwork.deleteEmoji(emojiId: emojiId)
        } else {
            let res = await emojiNetwork.postEmoji(challengeId: challengeId, emojiType: emojiType)
            switch res {
            case .success(let emojiId):
                switch emojiType {
                case .like:
                    self.emoji?.likeId = emojiId
                case .hate:
                    self.emoji?.hateId = emojiId
                }
                updateSucceeded = true
            case .failure:
                updateSucceeded = false
            }
        }
        return updateSucceeded
    }
    
    @MainActor
    func getEmoji(challengeId: String) async {
        let getEmojiResult = await emojiNetwork.getEmoji(challengeId: challengeId)
        switch getEmojiResult {
        case .success(let model):
            self.emoji = model.data
        case .failure:
            self.emoji = nil
        }
    }
    
    func reportChallenge() async {
        let challengeId = self.itemList[currentIdx].id
        let result = await challengeNetwork.patchChallenge(challengeId: challengeId)
        switch result {
        case .success:
            await getData()
        case .failure(let err):
            Log("챌린지 신고 실패 \(challengeId) \(err.localizedDescription)")
        }
    }
    
    func handleDragChange(_ value: DragGesture.Value) {
        if value.translation.height < 0 && currentIdx != itemList.count-1 {
            isScrolling = true
            
            itemList[currentIdx].offset = value.translation.height
            
            /// 다음 이미지 y축 올리는 효과
            if currentIdx + 1 != itemList.count-1 {
                itemList[currentIdx + 1].offset = -12
            }
        }
    }
    
    func handleDragEnd(_ value: DragGesture.Value, _ viewHeight: CGFloat) {
        if value.translation.height < 0 {  /// 위로 스크롤
            if currentIdx != itemList.count-1 {
                itemList[currentIdx].offset = -viewHeight
                if currentIdx + 1 != itemList.count-1 {
                    itemList[currentIdx + 1].offset = 0
                }
                currentIdx += 1
            } else {
                itemList[currentIdx].offset = 0
            }
        } else {  /// 아래로 스크롤
            if currentIdx > 0 {
                if value.translation.height > 0 {
                    itemList[currentIdx - 1].offset = 0
                    currentIdx -= 1
                } else {
                    itemList[currentIdx - 1].offset = -viewHeight
                }
            }
        }
        isScrolling = false
    }
    
    func calculateOpacity(itemIndex: Int) -> CGFloat {
        switch abs(itemIndex - currentIdx) {
        case 0:
            return isScrolling ? 0.5 : 1 /// 활성화된 아이템이 >> 화면 스크롤 중이면 0.5, 스크롤 중이 아니면 1
        case 1:
            return isScrolling ? 1 : 0.5  /// 다음에 보여질 아이템이 >> 화면 스크롤 중이면 1, 스크롤 중이 아니면 0.5
        case 2:
            return 0.2
        default:
            return 0
        }
    }
}

struct ApprovalViewModelItem: Identifiable {
    let id: String
    var title: String
    var image: UIImage?
    var imageId: String
    var offset: CGFloat
    var nickname: String
    var time: String
    
    init(id: String = UUID().uuidString, title: String, image: UIImage? = nil, imageId: String, offset: CGFloat, nickname: String, time: String) {
        self.id = id
        self.title = title
        self.image = image
        self.imageId = imageId
        self.offset = offset
        self.nickname = nickname
        self.time = time
    }
    
    init(challenge: Challenge) {
        self.id = challenge.challengeId
        self.title = challenge.missionTitle ?? ""
        self.image = nil
        self.imageId = challenge.receiptImageId
        self.offset = 0
        // TODO: nickname 옵셔널 해제
        self.nickname = challenge.userNickName ?? "일상"
        self.time = challenge.createdAt.timeAgoSinceDate()
    }
    
    static var mockData = [
        ApprovalViewModelItem(title: "바닐라라떼마시기", imageId: "IMRE2024061314275774", offset: 0, nickname: "일상1", time: "3시간 전"),
        ApprovalViewModelItem(title: "바닐라라떼마시기", imageId: "IMRE2024061314275774", offset: 0, nickname: "일상2", time: "1시간 전"),
        ApprovalViewModelItem(title: "바닐라라떼마시기", imageId: "IMRE2024061314275774", offset: 0, nickname: "일상3", time: "2시간 전"),
        ApprovalViewModelItem(title: "바닐라라떼마시기", imageId: "IMRE2024061314275774", offset: 0, nickname: "일상4", time: "2시간 전"),
        ApprovalViewModelItem(title: "바닐라라떼마시기", imageId: "IMRE2024061314275774", offset: 0, nickname: "일상5", time: "1시간 전"),
        ApprovalViewModelItem(title: "바닐라라떼마시기", imageId: "IMRE2024061314275774", offset: 0, nickname: "일상6", time: "3시간 전"),
        ApprovalViewModelItem(title: "바닐라라떼마시기", imageId: "IMRE2024061314275774", offset: 0, nickname: "일상7", time: "2시간 전"),
        ApprovalViewModelItem(title: "바닐라라떼마시기", imageId: "IMRE2024061314275774", offset: 0, nickname: "일상8", time: "3시간 전")
    ]
}
