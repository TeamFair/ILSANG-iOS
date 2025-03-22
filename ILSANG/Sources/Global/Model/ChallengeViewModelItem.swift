//
//  ChallengeViewModelItem.swift
//  ILSANG
//
//  Created by Lee Jinhee on 2/15/25.
//

import UIKit

struct ChallengeViewModelItem: Hashable {
    let challengeId: String
    let userNickName: String?
    let missionTitle: String?
    let challengeImageId: String?
    let writerImageId: String?
    let status: String
    let createdAt: String
    let likeCnt, hateCnt: Int
    var writerImage: UIImage?
    var challengeImage: UIImage?
    
    init(challenge: Challenge) {
        self.challengeId = challenge.challengeId
        self.userNickName = challenge.userNickName
        self.missionTitle = challenge.missionTitle
        self.challengeImageId = challenge.receiptImageId
        self.writerImageId = challenge.questImageId
        self.status = challenge.status
        self.createdAt = challenge.createdAt
        self.likeCnt = challenge.likeCnt
        self.hateCnt = challenge.hateCnt
        self.writerImage = nil
        self.challengeImage = nil
    }
    
    static let mockData = ChallengeViewModelItem(challenge: .challengeMockData)
}
