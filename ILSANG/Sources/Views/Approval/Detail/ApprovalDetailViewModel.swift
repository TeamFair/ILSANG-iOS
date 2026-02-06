//
//  ApprovalDetailViewModel.swift
//  ILLSANG
//
//  Created by Lee Jinhee on 12/12/25.
//

import UIKit

enum ApprovalDetailAction {
    case load
    case reload
    case mission
    case profileTapped(userId: String)
    case missionHistoryEllipsisTapped
    case missionHistoryReport
    case createComment
    case commentAction(CommentAction)
}

enum ApprovalDetailViewEvent {
    case focusCommentField
    case scrollToComment(Int)
}

final class ApprovalDetailViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var viewStatus: ViewStatus = .loading
    @Published var comments: [CommentItem] = []
    @Published var activeMenuCommentId: Int?
    @Published var activeMissionHistoryMenu: Bool = false
    @Published var comment: String = ""
    @Published var replyingToComment: (id: Int, nickname: String)? = nil
    
    @Published var showAlertType: AlertType?
    @Published var event: ApprovalDetailViewEvent?

    // MARK: - Stored Properties
    let missionHistory: ApprovalMissionHistoryItem
    private let userId = UserService.shared.currentUser?.id ?? ""
    let maxCommentLength = 300
    
    private let commentRepository: CommentRepositoryInterface
    private let missionHistoryRepository: MissionHistoryRepositoryInterface
    var createCommentAble: Bool {
        !comment.isEmpty && comment.count <= maxCommentLength
    }
    
    var onAction: ((ApprovalDetailAction) -> Void)? = nil
    
    init(
        missionHistory: ApprovalMissionHistoryItem,
        commentRepository: CommentRepositoryInterface,
        missionHistoryRepository: MissionHistoryRepositoryInterface,
    ) {
        self.missionHistory = missionHistory
        self.commentRepository = commentRepository
        self.missionHistoryRepository = missionHistoryRepository
        
        Log("✨ ApprovalDetailViewModel: init")
    }
    
    deinit {
        Log("✨ ApprovalDetailViewModel: deinit")
    }
    
    @MainActor
    func send(_ action: ApprovalDetailAction) {
        switch action {
        case .load, .reload:
            Task { await loadInitialDataWithLoadingState() }
        case .mission:
            print("") // FIXME: 상세 시트 연결
        case .missionHistoryEllipsisTapped:
            activeMissionHistoryMenu = true
        case .missionHistoryReport:
            print("") // FIXME: 신고 화면 이동
        case .profileTapped(let userId):
            print("\(userId)") // FIXME: 프로필 화면 연결
        case .createComment:
            Task { await createComment() }
        case .commentAction(let commentAction):
            switch commentAction {
            case .delete(let id):
                Task { await deleteComment(commentId: id) }
            case .report(let id):
                print("\(id)")  // FIXME: 신고 화면 이동
            case .reply(let id, let name):
                replyingToComment = (id, name)
                event = .focusCommentField
                if let index = comments.firstIndex(where: { $0.id == id }) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        self.event = .scrollToComment(index)
                    }
                }
            case .showUserProfile(let userId):
                print("\(userId)") // FIXME: 프로필 화면 연결
            }
        }
    }
    
    @MainActor
    private func loadInitialDataWithLoadingState() async {
        changeViewStatus(.loading)
        let minimumDelay: UInt64 = 300_000_000 // 최소 응답 지연 시간 추가 (0.3초)
        async let dataLoad: Void = loadComments()
        async let delay: Void = Task.sleep(nanoseconds: minimumDelay)
        _ = try? await (dataLoad, delay)
        changeViewStatus(.loaded)
    }
    
    @MainActor
    private func loadComments() async {
        let comments = await fetchComments()
        self.comments = await setupProfileImages(comments)
    }
    
    /// 3. 이미지 병합: 각 챌린지에 이미지 정보를 추가
    private func setupProfileImages(_ comments: [CommentItem]) async -> [CommentItem] {
        var comments = comments
        await withTaskGroup(of: (Int, UIImage?).self) { group in
            for (index, comment) in comments.enumerated() {
                group.addTask {
                    guard let imageId = comment.profileImageId else {
                        return (index, nil)
                    }
                    let image = await ImageCacheService.shared.loadImageAsync(imageId: imageId)
                    return (index, image)
                }
            }
            
            for await (index, image) in group {
                if let image {
                    comments[index].profileImage = image
                }
            }
        }
        
        return comments
    }
    
    /// 뷰 상태를 변경합니다.
    /// - Parameter viewStatus: 변경할 새로운 뷰 상태.
    @MainActor
    private func changeViewStatus(_ viewStatus: ViewStatus) {
        self.viewStatus = viewStatus
    }
    
    // MARK: - API 호출부
    private func fetchComments() async -> [CommentItem] {
        let result = await commentRepository.fetchComments(missionHistoryId: missionHistory.id)
        switch result {
        case .success(let comments):
            return comments.flatMap { $0.toFlatItems(currentUserId: userId, missionHistoryUserId: missionHistory.userId) }
        case .failure:
            return []
        }
    }
    
    @MainActor
    private func createComment() async {
        let result = await commentRepository.createComment(missionHistoryId: missionHistory.id, parentId: replyingToComment?.id ?? nil, comment: comment)
        switch result {
        case .success:
            replyingToComment = nil
            comment = ""
             await loadComments()
        case .failure:
            showAlertType = .CommentCreateFail
            // TODO: 1분이내 등록 불가 대응
        }
    }
    
    @MainActor
    private func deleteComment(commentId: Int) async {
        let result = await commentRepository.deleteComment(commentId: commentId)
        switch result {
        case .success:
            if let idx = comments.firstIndex(where: { $0.id == commentId }) {
                comments[idx].state = .deleted
            }
        case .failure:
            // FIXME: 실패 알럿 추가
            showAlertType = .CommentDeleteFail
        }
    }
}
