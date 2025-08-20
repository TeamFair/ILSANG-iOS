//
//  ApprovalMissionHistoryItem.swift
//  ILSANG
//
//  Created by Lee Jinhee on 8/18/25.
//

import UIKit

struct ApprovalMissionHistoryItem: Identifiable {
    let id: Int
    let title: String
    let displayDate: String
    var likeCount: Int
    var hateCount: Int
    let viewCount: Int
    let imageId: String
    var image: UIImage?
    let commercialAreaName: String?
    let userId: String
    let nickname: String
    let profileImageId: String?
    var profileImage: UIImage?
    let userTitle: UserTitle?
    var emoji: Emoji?
    
    static var mockDataList = [
        ApprovalMissionHistoryItem(
            id: 1,
            title: "첫 번째 미션",
            displayDate: "2025-08-19",
            likeCount: 12,
            hateCount: 2,
            viewCount: 45,
            imageId: "image_001",
            image: nil,
            commercialAreaName: "강남구",
            userId: "",
            nickname: "유저1",
            profileImageId: "profile_001",
            profileImage: nil,
            userTitle: UserTitle(name: "칭호1", grade: .standard),
            emoji: Emoji(isLike: true, isHate: false)
        ),
        ApprovalMissionHistoryItem(
            id: 2,
            title: "두 번째 미션",
            displayDate: "2025-08-18",
            likeCount: 8,
            hateCount: 1,
            viewCount: 30,
            imageId: "image_002",
            image: nil,
            commercialAreaName: "서초구",
            userId: "",
            nickname: "유저2",
            profileImageId: "profile_002",
            profileImage: nil,
            userTitle: UserTitle(name: "칭호2", grade: .legend),
            emoji: Emoji(isLike: true, isHate: false)
        ),
        ApprovalMissionHistoryItem(
            id: 3,
            title: "세 번째 미션",
            displayDate: "2025-08-17",
            likeCount: 20,
            hateCount: 0,
            viewCount: 60,
            imageId: "image_003",
            image: nil,
            commercialAreaName: "송파구",
            userId: "",
            nickname: "유저3",
            profileImageId: "profile_003",
            profileImage: .img2,
            userTitle: UserTitle(name: "칭호3", grade: .rare),
            emoji: Emoji(isLike: true, isHate: false)
        )
    ]
    
    static let failedData = ApprovalMissionHistoryItem(
        id: 0,
        title: "불러올 수 없습니다",
        displayDate: "",
        likeCount: 0,
        hateCount: 0,
        viewCount: 0,
        imageId: "",
        commercialAreaName: nil,
        userId: "",
        nickname: "",
        profileImageId: nil,
        userTitle: nil
    )
}
