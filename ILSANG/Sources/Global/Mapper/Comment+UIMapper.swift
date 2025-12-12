//
//  Comment+UIMapper.swift
//  ILLSANG
//
//  Created by Lee Jinhee on 12/12/25.
//

extension Comment {
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
        
        return [item] + children.flatMap {
            $0.toFlatItems(
                currentUserId: currentUserId,
                missionHistoryUserId: missionHistoryUserId
            )
        }
    }
}
