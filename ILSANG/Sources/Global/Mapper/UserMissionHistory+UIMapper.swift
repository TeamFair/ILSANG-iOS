//
//  UserMissionHistory+UIMapper.swift
//  ILLSANG
//
//  Created by Lee Jinhee on 8/28/25.
//

import Foundation

extension UserMissionHistory {
    func toItem() -> UserMissionHistoryItem {
        UserMissionHistoryItem(
            missionHistoryId: missionHistoryId,
            title: title,
            createdAt: createdAt,
            submitImageId: submitImageId,
            submitImage: nil,
            questImageId: questImageId,
            questImage: nil,
            viewCount: viewCount,
            likeCount: likeCount
        )
    }
}
