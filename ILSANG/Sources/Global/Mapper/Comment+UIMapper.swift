//
//  Comment+UIMapper.swift
//  ILLSANG
//
//  Created by Lee Jinhee on 12/12/25.
//

extension Comment {
    static func toFlatItems(
        _ comments: [Comment],
        currentUserId: String,
        missionHistoryUserId: String
    ) -> [CommentItem] {
        
        comments
        // 상위 댓글 정렬
            .sorted {
                ($0.createdAt ?? .distantPast) < ($1.createdAt ?? .distantPast)
            }
        // 각 댓글을 flat 구조로 변환
            .flatMap {
                $0.toFlatItems(
                    currentUserId: currentUserId,
                    missionHistoryUserId: missionHistoryUserId
                )
            }
    }
    
    func toFlatItems(currentUserId: String, missionHistoryUserId: String, depth: Int = 0) -> [CommentItem] {
        let commentState: CommentState
        if deleteYn {
            commentState = .deleted
        } else if hasReportedYn {
            commentState = .reported
        } else {
            commentState = .normal
        }
        
        // children 제거한 구조
        let item = CommentItem(
            id: id,
            parentId: parentId,
            userId: writer.userId,
            nickname: writer.nickname,
            profileImageId: writer.profileImageId,
            profileImage: nil,
            userTitle: writer.title,
            content: comment,
            date: createdAt,
            isWriter: missionHistoryUserId == writer.userId,
            isReplyComment: parentId != nil,
            isFromCurrentUser: currentUserId == writer.userId,
            state: commentState
        )
        
        let sortedChildren = children
            .flatMap {
                $0.toFlatItems(
                    currentUserId: currentUserId,
                    missionHistoryUserId: missionHistoryUserId
                )
            }
            .sorted {
                ($0.date ?? .distantPast) < ($1.date ?? .distantPast)
            }

        return [item] + sortedChildren
    }
}
