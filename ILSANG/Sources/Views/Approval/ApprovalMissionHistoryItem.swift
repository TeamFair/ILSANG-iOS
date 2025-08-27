//
//  ApprovalMissionHistoryItem.swift
//  ILSANG
//
//  Created by Lee Jinhee on 8/18/25.
//

import UIKit


struct UserEmojis {
    var emojis: Set<EmojiType> = []
    
    mutating func toggle(_ emoji: EmojiType) {
        if emojis.contains(emoji) {
            emojis.remove(emoji)
        } else {
            emojis.insert(emoji)
        }
    }
    
    func isSelected(_ emoji: EmojiType) -> Bool {
        emojis.contains(emoji)
    }
}

@Observable
class ApprovalMissionHistoryItem: Identifiable {
    let id: Int
    let title: String
    let displayDate: String
    var likeCount: Int
    var hateCount: Int
    let viewCount: Int
    let imageId: String
    var image: UIImage?
    let commercialAreaCode: String?
    var commercialAreaName: String?
    let userId: String
    let nickname: String
    let profileImageId: String?
    var profileImage: UIImage?
    let userTitle: UserTitle?
    var emojis: UserEmojis
    
    init(id: Int, title: String, displayDate: String, likeCount: Int, hateCount: Int, viewCount: Int, imageId: String, image: UIImage? = nil, commercialAreaCode: String?, commercialAreaName: String? = nil, userId: String, nickname: String, profileImageId: String?, profileImage: UIImage? = nil, userTitle: UserTitle?, emojis: UserEmojis) {
        self.id = id
        self.title = title
        self.displayDate = displayDate
        self.likeCount = likeCount
        self.hateCount = hateCount
        self.viewCount = viewCount
        self.imageId = imageId
        self.image = image
        self.commercialAreaCode = commercialAreaCode
        self.commercialAreaName = commercialAreaName
        self.userId = userId
        self.nickname = nickname
        self.profileImageId = profileImageId
        self.profileImage = profileImage
        self.userTitle = userTitle
        self.emojis = emojis
    }
    
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
            commercialAreaCode: "S01",
            commercialAreaName: "강남구",
            userId: "",
            nickname: "유저1",
            profileImageId: "profile_001",
            profileImage: nil,
            userTitle: UserTitle(name: "칭호1", grade: .standard),
            emojis: .init(emojis: [.hate])
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
            commercialAreaCode: "S01",
            commercialAreaName: "강남구",
            userId: "",
            nickname: "유저2",
            profileImageId: "profile_002",
            profileImage: nil,
            userTitle: UserTitle(name: "칭호2", grade: .legend),
            emojis: .init(emojis: [.hate])
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
            commercialAreaCode: "S01",
            commercialAreaName: "강남구",
            userId: "",
            nickname: "유저3",
            profileImageId: "profile_003",
            profileImage: .img2,
            userTitle: UserTitle(name: "칭호3", grade: .rare),
            emojis: .init(emojis: [.hate])
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
        commercialAreaCode: nil,
        commercialAreaName: nil,
        userId: "",
        nickname: "",
        profileImageId: nil,
        userTitle: nil,
        emojis: .init(emojis: [])
    )
}
