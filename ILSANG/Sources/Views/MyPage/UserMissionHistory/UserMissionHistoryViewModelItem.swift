//
//  UserMissionHistoryViewModelItem.swift
//  ILLSANG
//
//  Created by Lee Jinhee on 8/28/25.
//

import UIKit

@Observable
class UserMissionHistoryViewModelItem {
    let missionHistoryId: Int
    let title, createdAt: String
    let submitImageId: String?
    var submitImage: UIImage?
    let questImageId: String?
    var questImage: UIImage?
    let viewCount: Int
    var likeCount: Int
    
    init(
        missionHistoryId: Int,
        title: String,
        createdAt: String,
        submitImageId: String?,
        submitImage: UIImage?,
        questImageId: String?,
        questImage: UIImage?,
        viewCount: Int,
        likeCount: Int
    ) {
        self.missionHistoryId = missionHistoryId
        self.title = title
        self.createdAt = createdAt
        self.submitImageId = submitImageId
        self.submitImage = submitImage
        self.questImageId = questImageId
        self.questImage = questImage
        self.viewCount = viewCount
        self.likeCount = likeCount
    }
}
