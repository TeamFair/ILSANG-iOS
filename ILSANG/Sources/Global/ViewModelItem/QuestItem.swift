//
//  Quest.swift
//  ILSANG
//
//  Created by Lee Jinhee on 5/22/24.
//

import UIKit

@Observable
class QuestItem: Hashable, Identifiable {
    static func == (lhs: QuestItem, rhs: QuestItem) -> Bool {
        lhs.id == rhs.id &&
        lhs.questType == rhs.questType &&
        lhs.repeatType == rhs.repeatType &&
        lhs.favoriteYn == rhs.favoriteYn &&
        lhs.rewards == rhs.rewards &&
        lhs.missions == rhs.missions &&
        lhs.mainImage == rhs.mainImage &&
        lhs.image == rhs.image &&
        lhs.userRank == rhs.userRank
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    let id: Int
    let title: String
    let writer: String
    let questType: QuestType?
    let repeatType: RepeatType?
    let rewards: [Reward]?
    var missions: [Mission]
    var coupons: [CouponItem]
    let expireDate: Date?
    let imageId: String?
    var image: UIImage?
    let mainImageId: String?
    var mainImage: UIImage?
    let userRank: Int?
    var favoriteYn: Bool
    var lastCompleteDate: Date?
    var commercialAreaCode: String?
    let isMyIllsangZone: Bool
    
    init(
        id: Int,
        title: String,
        writer: String,
        questType: QuestType?,
        repeatType: RepeatType?,
        rewards: [Reward]?,
        missions: [Mission],
        coupons: [CouponItem],
        expireDate: Date?,
        imageId: String?,
        image: UIImage?,
        mainImageId: String?,
        mainImage: UIImage?,
        userRank: Int?,
        favoriteYn: Bool,
        lastCompleteDate: Date?,
        commercialAreaCode: String?,
        isMyIllsangZone: Bool
    ) {
        self.id = id
        self.title = title
        self.writer = writer
        self.questType = questType
        self.repeatType = repeatType
        self.rewards = rewards
        self.missions = missions
        self.coupons = coupons
        self.expireDate = expireDate
        self.imageId = imageId
        self.image = image
        self.mainImageId = mainImageId
        self.mainImage = mainImage
        self.userRank = userRank
        self.favoriteYn = favoriteYn
        self.lastCompleteDate = lastCompleteDate
        self.commercialAreaCode = commercialAreaCode
        self.isMyIllsangZone = isMyIllsangZone
    }
    
    var missionType: MissionType { missions.first?.type ?? .photo }
    var challengeImages: [UIImage] = []
    var missionId: Int { missions.first?.id ?? 0}
    var coupon: CouponItem? { coupons.first }
    var hasCouponReward: Bool { !coupons.isEmpty }
    
    func totalRewardPoint() -> Int {
        guard let rewards else { return 0 }
        return rewards.reduce(0) { total, reward in
            var point = reward.point
            
            // 내 일상존이고, contribution 포인트면 두 배로 계산
            if isMyIllsangZone, reward.pointType == .contribution {
                point *= 2
            }
            
            return total + point
        }
    }
    
    /// 반복 퀘스트가 현재 잠금 상태인지 여부
    var isRepeatDisabled: Bool {
        guard questType == .repeat,
              let repeatType,
              let lastCompleteDate
        else { return false }
        
        return Date() < nextAvailableDate(for: repeatType, from: lastCompleteDate)
    }
    
    var nextAvailableDate: Date? {
        guard questType == .repeat,
              let repeatType,
              let lastCompleteDate
        else { return .now }
        return nextAvailableDate(for: repeatType, from: lastCompleteDate)
    }
    
    /// 반복 퀘스트 재시작까지 남은 시간 텍스트
    var repeatStatusText: String? {
        guard isRepeatDisabled,
              let repeatType,
              let lastCompleteDate
        else {
            return nil
        }

        let next = nextAvailableDate(for: repeatType, from: lastCompleteDate)
        let remaining = next.timeIntervalSinceNow

        // 만약 다음 반복 주기가 퀘스트 종료일 이후라면 종료 문구 표시
        if let expireDate, next >= expireDate {
            let remainingToExpire = expireDate.timeIntervalSinceNow
            if remainingToExpire <= 0 {
                return "퀘스트 종료"
            } else if remainingToExpire > 24 * 3600 {
                let days = ceil(remainingToExpire / (24 * 3600))
                return "\(Int(days))일 후 퀘스트 종료"
            } else {
                let hours = ceil(remainingToExpire / 3600)
                return "\(Int(hours))시간 후 퀘스트 종료"
            }
        }

        // 기본: 반복 가능까지 남은 시간
        if remaining > 24 * 3600 {
            let days = ceil(remaining / (24 * 3600))
            return "\(Int(days))일 후 다시 시작"
        } else {
            let hours = ceil(remaining / 3600)
            return "\(Int(hours))시간 후 다시 시작"
        }
    }

    /// repeatType에 따른 다음 재시작 가능 날짜 계산
    private func nextAvailableDate(for type: RepeatType, from date: Date) -> Date {
        let calendar = Calendar.current

        switch type {
        case .daily:
            // 다음날 00:00
            if let nextDay = calendar.date(byAdding: .day, value: 1, to: date) {
                return calendar.startOfDay(for: nextDay)
            }

        case .weekly:
            // 다음 주 월요일 00:00
            let nextWeek = calendar.date(byAdding: .weekOfYear, value: 1, to: date) ?? date
            var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: nextWeek)
            components.weekday = 2 // 월요일 (1=일요일, 2=월요일)
            return calendar.date(from: components).flatMap { calendar.startOfDay(for: $0) } ?? date

        case .monthly:
            // 다음달 1일 00:00
            let nextMonth = calendar.date(byAdding: .month, value: 1, to: date) ?? date
            var components = calendar.dateComponents([.year, .month], from: nextMonth)
            components.day = 1
            return calendar.date(from: components).flatMap { calendar.startOfDay(for: $0) } ?? date
        }

        return date
    }
    
    func updateChallengeImages() async {
        let challengeImageIds = missions
            .compactMap { $0.exampleImageIds }
            .flatMap { $0 }
        
        let newImages = await withTaskGroup(of: UIImage?.self) { group -> [UIImage] in
            var images: [UIImage] = []
            
            for challengeImageId in challengeImageIds {
                group.addTask {
                    await ImageCacheService.shared.loadImageAsync(imageId: challengeImageId)
                }
            }
            
            for await image in group {
                if let image = image {
                    images.append(image)
                }
            }
            
            return images
        }
        self.challengeImages = newImages
    }
}

extension QuestItem {
    static let mockImageId = "IMQU2024071520500801"
    
    static let mockData: QuestItem = QuestItemBuilder()
        .setTitle("러닝 30분하기")
        .setReward([Reward(point: 110, pointType: .metro), Reward(point: 10, pointType: .commercial), Reward(point: 10, pointType: .contribution)])
        .setFavoriteYn(true)
        .setChallengeImageIds([""])
        .build()
    static let mockRepeatData: QuestItem = QuestItemBuilder()
        .setTitle("러닝 30분하기")
        .setRepeatType(.daily)
        .setCoupons([CouponItem.mockData])
        .setReward([Reward(point: 110, pointType: .metro), Reward(point: 10, pointType: .commercial), Reward(point: 10, pointType: .contribution)])
        .setFavoriteYn(true)
        .setChallengeImageIds([""])
        .setCustomerRank(2)
        .build()
    static let mockOXData: QuestItem = QuestItemBuilder()
        .setTitle("러닝 30분하기")
        .setNormalType()
        .setCoupons([CouponItem.mockData])
        .setMission(.init(id: 0, type: .quiz(.ox), exampleImageIds: []))
        .setReward([Reward(point: 110, pointType: .metro), Reward(point: 10, pointType: .commercial), Reward(point: 10, pointType: .contribution)])
        .setFavoriteYn(true)
        .build()
    
    static let mockQuestList: [QuestItem] = [mockData, mockRepeatData]
}
