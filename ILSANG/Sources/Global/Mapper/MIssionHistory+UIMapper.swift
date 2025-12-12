//
//  MIssionHistory+UIMapper.swift
//  ILLSANG
//
//  Created by Lee Jinhee on 8/18/25.
//

import Foundation

extension MissionHistory {
    func toApprovalItem() -> ApprovalMissionHistoryItem {
        return ApprovalMissionHistoryItem(
            id: id,
            title: title,
            displayDate: createdAt.toDisplayFormat(),
            likeCount: likeCount,
            viewCount: viewCount,
            commentCount: commentCount,
            imageId: imageId,
            image: nil,
            commercialAreaCode: commercialAreaCode,
            commercialAreaName: nil,
            userId: userId,
            nickname: nickname,
            profileImageId: profileImageId,
            profileImage: nil,
            userTitle: userTitle,
            emojis: UserEmojis(emojis: Set(emojis)),
            questType: questType,
            repeatType: repeatType,
            writer: writer,
            expireAt: expireAt,
            lastCompleteDate: lastCompleteDate
        )
    }
    
    func toApprovalItem(quest: QuestItem) -> ApprovalMissionHistoryItem {
        return ApprovalMissionHistoryItem(
            id: id,
            title: title,
            displayDate: createdAt.toDisplayFormat(),
            likeCount: likeCount,
            viewCount: viewCount,
            commentCount: commentCount,
            imageId: imageId,
            image: nil,
            commercialAreaCode: commercialAreaCode,
            commercialAreaName: nil,
            userId: userId,
            nickname: nickname,
            profileImageId: profileImageId,
            profileImage: nil,
            userTitle: userTitle,
            emojis: UserEmojis(emojis: Set(emojis)),
            questType: quest.questType,
            repeatType: quest.repeatType,
            writer: quest.writer,
            expireAt: quest.expireDate,
            lastCompleteDate: quest.lastCompleteDate
        )
    }
}

// TODO: 지역 시스템 >서버 스펙 확인해서 재수정
extension Date {
    enum DisplayFormat: String {
        case full = "yyyy.MM.dd HH:mm"
        case short = "yyyy.MM.dd"
    }
    
    func toDisplayFormat(_ format: DisplayFormat = .full) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format.rawValue
        return formatter.string(from: self)
    }
}
