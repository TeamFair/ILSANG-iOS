//
//  CommentResponse.swift
//  ILSANG
//
//  Created by Lee Jinhee on 12/12/25.
//

struct CommentResponse: Decodable {
    let id: Int
    let parentId: Int?
    let comment: String
    let writer: CommentWriterResponse
    let status: String
    let createdAt: String
    let hasReportedYn: Bool
    let deleteYn: Bool
    let children: [CommentResponse]

    struct CommentWriterResponse: Decodable {
        let userId: String
        let nickname: String
        let profileImageId: String?
        let title: UserTitleResponse?
    }
}
