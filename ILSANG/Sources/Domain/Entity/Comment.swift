//
//  Comment.swift
//  ILLSANG
//
//  Created by Lee Jinhee on 12/12/25.
//

import Foundation

struct Comment {
    let id: Int
    let parentId: Int?
    let comment: String
    let writer: CommentWriter
    let status: String
    let createdAt: Date?
    let hasReportedYn: Bool
    let deleteYn: Bool
    let children: [Comment]
    
    struct CommentWriter {
        let userId: String
        let nickname: String
        let profileImageId: String?
        let title: UserTitle?
    }
}
