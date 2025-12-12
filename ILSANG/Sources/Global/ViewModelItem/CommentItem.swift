//
//  CommentItem.swift
//  ILLSANG
//
//  Created by Lee Jinhee on 11/29/25.
//

import UIKit

struct CommentItem: Identifiable {
    let id: Int
    let userId: String
    let nickname: String
    let profileImageId: String?
    var profileImage: UIImage?
    let userTitle: UserTitle?
    
    let content: String
    let date: Date?
    
    let isWriter: Bool
    let isReplyComment: Bool
    let isFromCurrentUser: Bool
    
    var state: CommentState
}

enum CommentState {
    case normal
    case deleted
    case reported
}

extension CommentItem {
    static let mockList: [CommentItem] = [
        
        // MARK: - Normal Comments (정상 댓글)
        CommentItem(
            id: 0,
            userId: "u1",
            nickname: "김이선",
            profileImageId: nil,
            profileImage: nil,
            userTitle: .none,
            content: "기본 댓글 기본 댓글 기본 댓글 기본 댓글 기본 댓글 기본 댓글 기본 댓글 기본 댓글 기본 댓글 기본 댓글기본댓글기본댓글댓글기본댓글기본댓글댓글기본댓글기본댓글댓글기본댓글기본댓글",
            date: .now,
            isWriter: false,
            isReplyComment: false,
            isFromCurrentUser: false,
            state: .normal
        ),
        CommentItem(
            id: 1,
            userId: "u1",
            nickname: "김이선",
            profileImageId: nil,
            profileImage: nil,
            userTitle: .none,
            content: "작성자 댓글",
            date: .now,
            isWriter: true,
            isReplyComment: false,
            isFromCurrentUser: false,
            state: .normal
        ),
        CommentItem(
            id: 2,
            userId: "u1",
            nickname: "김이선",
            profileImageId: nil,
            profileImage: nil,
            userTitle: .none,
            content: "현재 유저 댓글",
            date: .now,
            isWriter: false,
            isReplyComment: false,
            isFromCurrentUser: true,
            state: .normal
        ),
        CommentItem(
            id: 3,
            userId: "u1",
            nickname: "김이선",
            profileImageId: nil,
            profileImage: nil,
            userTitle: .none,
            content: "현재 유저가 신고한 댓글",
            date: .now,
            isWriter: false,
            isReplyComment: false,
            isFromCurrentUser: true,
            state: .normal
        ),
        
        // MARK: - Normal Replies (정상 대댓글)
        CommentItem(
            id: 4,
            userId: "u2",
            nickname: "김이선",
            profileImageId: nil,
            profileImage: nil,
            userTitle: .none,
            content: "기본 대댓글",
            date: .now,
            isWriter: false,
            isReplyComment: true,
            isFromCurrentUser: false,
            state: .normal
        ),
        CommentItem(
            id: 5,
            userId: "u2",
            nickname: "김이선",
            profileImageId: nil,
            profileImage: nil,
            userTitle: .none,
            content: "현재 유저 대댓글",
            date: .now,
            isWriter: false,
            isReplyComment: true,
            isFromCurrentUser: true,
            state: .normal
        ),
        CommentItem(
            id: 6,
            userId: "u2",
            nickname: "김이선",
            profileImageId: nil,
            profileImage: nil,
            userTitle: .none,
            content: "현재 유저 신고한 대댓글",
            date: .now,
            isWriter: false,
            isReplyComment: true,
            isFromCurrentUser: true,
            state: .normal
        ),
        
        // MARK: - Deleted Comments (삭제된 댓글)
        CommentItem(
            id: 7,
            userId: "u3",
            nickname: "삭제된 댓글",
            profileImageId: nil,
            profileImage: nil,
            userTitle: .none,
            content: "",
            date: .now,
            isWriter: false,
            isReplyComment: false,
            isFromCurrentUser: false,
            state: .deleted
        ),
        
        // MARK: - Deleted Replies (삭제된 대댓글)
        CommentItem(
            id: 8,
            userId: "u3",
            nickname: "삭제된 대댓글",
            profileImageId: nil,
            profileImage: nil,
            userTitle: .none,
            content: "",
            date: .now,
            isWriter: false,
            isReplyComment: true,
            isFromCurrentUser: false,
            state: .deleted
        ),
        
        // MARK: - Reported Comments (신고 누적으로 블라인드된 댓글)
        CommentItem(
            id: 9,
            userId: "u4",
            nickname: "블라인드 댓글",
            profileImageId: nil,
            profileImage: nil,
            userTitle: .none,
            content: "",
            date: .now,
            isWriter: false,
            isReplyComment: false,
            isFromCurrentUser: false,
            state: .reported
        ),
        
        // MARK: - Reported Replies (블라인드 대댓글)
        CommentItem(
            id: 10,
            userId: "u4",
            nickname: "블라인드 대댓글",
            profileImageId: nil,
            profileImage: nil,
            userTitle: .none,
            content: "",
            date: .now,
            isWriter: false,
            isReplyComment: true,
            isFromCurrentUser: false,
            state: .reported
        )
    ]
}
