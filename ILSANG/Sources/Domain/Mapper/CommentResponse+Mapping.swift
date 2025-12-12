//
//  CommentResponse+Mapping.swift
//  ILLSANG
//
//  Created by Lee Jinhee on 12/12/25.
//

import Foundation

extension CommentResponse: DomainConvertible {
    func toDomain() -> Comment {
        Comment(
            id: id,
            parentId: parentId,
            comment: comment,
            writer: writer.toDomain(),
            status: status,
            createdAt: createdAt.toISO8601Date(),
            hasReportedYn: hasReportedYn,
            deleteYn: deleteYn,
            children: children.map({ $0.toDomain() })
        )
      }
}

extension CommentResponse.CommentWriterResponse: DomainConvertible {
    func toDomain() -> Comment.CommentWriter {
        let userTitle = title.flatMap { title in
            HonorGrade(rawValue: title.grade).flatMap { gradeEnum in
                UserTitle(titleHistoryId: nil, name: title.name, grade: gradeEnum, createdAt: nil)
            }
        }
        
       return Comment.CommentWriter(
            userId: userId,
            nickname: nickname,
            profileImageId: profileImageId,
            title: userTitle
        )
    }
}
