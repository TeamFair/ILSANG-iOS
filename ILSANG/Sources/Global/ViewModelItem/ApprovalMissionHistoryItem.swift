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
class ApprovalMissionHistoryItem: Identifiable, Equatable, Hashable {
    static func == (lhs: ApprovalMissionHistoryItem, rhs: ApprovalMissionHistoryItem) -> Bool {
        lhs.id == rhs.id &&
        lhs.title == rhs.title &&
        lhs.displayDate == rhs.displayDate &&
        lhs.likeCount == rhs.likeCount &&
        lhs.imageId == rhs.imageId &&
        lhs.userId == rhs.userId
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(title)
        hasher.combine(displayDate)
        hasher.combine(likeCount)
        hasher.combine(imageId)
        hasher.combine(userId)
    }
    
    let id: Int
    let title: String
    let displayDate: String
    var likeCount: Int
    let viewCount: Int
    let commentCount: Int
    let shareCount: Int
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
    
    var questType: QuestType?
    var repeatType: RepeatType?
    var writer: String?
    var expireAt: Date?
    var lastCompleteDate: Date?
    
    var questStatus: ApprovalQuestStatus {
        guard let expireAt, expireAt >= .now else { return .expired }
        switch questType {
        case .normal, .event:
            return lastCompleteDate == nil ? .able : .completed
        case .repeat:
            return .able
        default:
            return .expired
        }
    }
    
    init(
        id: Int,
        title: String,
        displayDate: String,
        likeCount: Int,
        viewCount: Int,
        shareCount: Int,
        commentCount: Int,
        imageId: String,
        image: UIImage? = nil,
        commercialAreaCode: String?,
        commercialAreaName: String? = nil,
        userId: String,
        nickname: String,
        profileImageId: String?,
        profileImage: UIImage? = nil,
        userTitle: UserTitle?,
        emojis: UserEmojis,
        questType: QuestType?,
        repeatType: RepeatType?,
        writer: String?,
        expireAt: Date?,
        lastCompleteDate: Date?
    ) {
        self.id = id
        self.title = title
        self.displayDate = displayDate
        self.likeCount = likeCount
        self.viewCount = viewCount
        self.shareCount = shareCount
        self.commentCount = commentCount
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
        self.questType = questType
        self.repeatType = repeatType
        self.writer = writer
        self.expireAt = expireAt
        self.lastCompleteDate = lastCompleteDate
    }
    
    static var mockDataList = [
        ApprovalMissionHistoryItem(
            id: 1,
            title: "첫 번째 미션",
            displayDate: "2025-08-19",
            likeCount: 12,
            viewCount: 45,
            shareCount: 10,
            commentCount: 0,
            imageId: "image_001",
            image: nil,
            commercialAreaCode: "S01",
            commercialAreaName: "강남구",
            userId: "",
            nickname: "유저1",
            profileImageId: "profile_001",
            profileImage: nil,
            userTitle: UserTitle(titleHistoryId: 1, name: "칭호1", grade: .standard, createdAt: .now),
            emojis: .init(emojis: []),
            questType: .event,
            repeatType: nil,
            writer: "작성자",
            expireAt: .now,
            lastCompleteDate: nil
        ),
        ApprovalMissionHistoryItem(
            id: 2,
            title: "두 번째 미션",
            displayDate: "2025-08-18",
            likeCount: 8,
            viewCount: 30,
            shareCount: 10,
            commentCount: 0,
            imageId: "image_002",
            image: nil,
            commercialAreaCode: "S01",
            commercialAreaName: "강남구",
            userId: "",
            nickname: "유저2",
            profileImageId: "profile_002",
            profileImage: nil,
            userTitle: UserTitle(titleHistoryId: 2, name: "칭호2", grade: .legend, createdAt: .now),
            emojis: .init(emojis: [.like]),
            questType: .event,
            repeatType: nil,
            writer: "작성자",
            expireAt: .now,
            lastCompleteDate: nil
        ),
        ApprovalMissionHistoryItem(
            id: 3,
            title: "세 번째 미션",
            displayDate: "2025-08-17",
            likeCount: 20,
            viewCount: 60,
            shareCount: 10,
            commentCount: 0,
            imageId: "image_003",
            image: nil,
            commercialAreaCode: "S01",
            commercialAreaName: "강남구",
            userId: "",
            nickname: "유저3",
            profileImageId: "profile_003",
            profileImage: .img2,
            userTitle: UserTitle(titleHistoryId: 3, name: "칭호3", grade: .rare, createdAt: .now),
            emojis: .init(emojis: [.like]),
            questType: .event,
            repeatType: nil,
            writer: "작성자",
            expireAt: .now,
            lastCompleteDate: nil
        )
    ]
    
    static let failedData = ApprovalMissionHistoryItem(
        id: 0,
        title: "불러올 수 없습니다",
        displayDate: "",
        likeCount: 0,
        viewCount: 0,
        shareCount: 10,
        commentCount: 0,
        imageId: "",
        commercialAreaCode: nil,
        commercialAreaName: nil,
        userId: "",
        nickname: "",
        profileImageId: nil,
        userTitle: nil,
        emojis: .init(emojis: []),
        questType: .event,
        repeatType: nil,
        writer: "작성자",
        expireAt: .now,
        lastCompleteDate: nil
    )
}
