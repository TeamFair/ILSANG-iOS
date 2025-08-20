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
            hateCount: hateCount,
            viewCount: viewCount,
            imageId: imageId,
            image: nil,
            commercialAreaName: commercialAreaName,
            userId: userId,
            nickname: nickname,
            profileImageId: profileImageId,
            profileImage: nil,
            userTitle: userTitle,
            emoji: nil
        )
    }
}

// TODO: 지역 시스템 >서버 스펙 확인해서 재수정
extension Date {
    func toDisplayFormat() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        formatter.dateFormat = "yyyy.MM.dd HH:mm"
        return formatter.string(from: self)
    }
}

//extension String {
//    func toDateFromServer() -> Date? {
//        let formatter = ISO8601DateFormatter()
//        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
//        return formatter.date(from: self)
//    }
//}
