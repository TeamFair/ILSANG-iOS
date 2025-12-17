//
//  MissionHistoryRepository.swift
//  ILLSANG
//
//  Created by Lee Jinhee on 8/18/25.
//

import Foundation

protocol MissionHistoryRepositoryInterface {
    func getRandomMissionHistories(page: Int, size: Int) async -> Result<(data: [MissionHistory], isLast: Bool), Error>
    func getMissionHistories(missionId: Int, page: Int, size: Int) async -> Result<(data: [MissionHistory], isLast: Bool), Error>
    func getMissionHistories(page: Int, size: Int, userId: String?, missionType: MissionType, filterType: MissionHistoryFilterType) async -> Result<(data: [UserMissionHistory], isLast: Bool), Error>
    func getMissionHistoryDetail(missionHistoryId: Int) async -> Result<UserMissionHistoryDetail, Error>
    func deleteMissionHistory(missionHistoryId: Int) async -> Bool
    func reportMissionHistory(missionHistoryId: Int, reason: String) async throws
}

final class MissionHistoryRepository: MissionHistoryRepositoryInterface {
    private let network: MissionHistoryNetwork
    
    init(network: MissionHistoryNetwork) {
        self.network = network
    }
    
    func getRandomMissionHistories(page: Int, size: Int) async -> Result<(data: [MissionHistory], isLast: Bool), Error> {
        let res = await network.getRandomMissionHistories(page: page, size: size)
        switch res {
        case .success(let response):
            let domainModels = response.content.map { $0.toDomain() }
            return .success((domainModels, response.isLast))
        case .failure(let error):
            return .failure(error)
        }
    }
    
    /// 미션 아이디별 조회 - 퀘스트 인증 예시 화면에서 사용
    func getMissionHistories(missionId: Int, page: Int, size: Int) async -> Result<(data: [MissionHistory], isLast: Bool), Error> {
        let res = await network.getMissionHistories(missionId: missionId, page: page, size: size)
        switch res {
        case .success(let response):
            let domainModels = response.content.map { $0.toDomain() }
            return .success((domainModels, response.isLast))
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func getMissionHistories(page: Int, size: Int, userId: String?, missionType: MissionType, filterType: MissionHistoryFilterType) async -> Result<(data: [UserMissionHistory], isLast: Bool), Error> {
        let res = await network.getMissionHistories(page: page, size: size, userId: userId, missionType: missionType, orderRewardDesc: filterType.orderRewardDesc, orderCreatedAtDesc: filterType.latest)
        switch res {
        case .success(let response):
            let domainModels = response.content.map { $0.toDomain() }
            return .success((domainModels, response.isLast))
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func getMissionHistoryDetail(missionHistoryId: Int) async -> Result<UserMissionHistoryDetail, Error> {
        let res = await network.getMissionHistoryDetail(missionHistoryId: missionHistoryId)
        switch res {
        case .success(let response):
            return .success(response.toDomain())
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func deleteMissionHistory(missionHistoryId: Int) async -> Bool {
        let res = await network.deleteMissionHistory(missionHistoryId: missionHistoryId)
        switch res {
        case .success:
            return true
        case .failure:
            return false
        }
    }
    
    // 신고하기
    func reportMissionHistory(missionHistoryId: Int, reason: String) async throws {
        let response = try await network.reportMissionHistory(missionHistoryId: missionHistoryId, reason: reason)
            .get()
        switch response.resultCode {
        case "S1000": // 신고 성공
            return
        case "R1000": // 이미 신고한 케이스
            throw ReportError.alreadyReported
        default:
            throw ReportError.unknown(code: response.resultCode)
        }
    }
}

final class MockMissionHistoryRepository: MissionHistoryRepositoryInterface {
    private let mockMissionHistory: [MissionHistory] = [
        MissionHistory(
            id: 0,
            title: "미션 타이틀",
            createdAt: .now,
            likeCount: 2,
            viewCount: 0,
            shareCount: 0,
            commentCount: 0,
            imageId: "",
            commercialAreaCode: "R100",
            userId: "",
            nickname: "닉네임",
            profileImageId: "",
            userTitle: nil,
            emojis: [],
            questId: 3,
            questType: .event,
            repeatType: nil,
            writer: "작성자",
            expireAt: .now,
            lastCompleteDate: nil
        )
    ]
    
    private let mockUserMissionHistory: [UserMissionHistory] = [
        UserMissionHistory(
            missionHistoryId: 1,
            title: "미션 타이틀",
            createdAt: "",
            submitImageId: nil,
            questImageId: nil,
            viewCount: 0,
            likeCount: 0,
            questType: .normal,
            repeatType: nil,
            missionType: .photo
        )
    ]
    
    func getRandomMissionHistories(page: Int, size: Int) async -> Result<(data: [MissionHistory], isLast: Bool), any Error> {
        .success((data: mockMissionHistory,  isLast: true))
    }
    
    func getMissionHistories(missionId: Int, page: Int, size: Int) async -> Result<(data: [MissionHistory], isLast: Bool), any Error> {
        .success((data: mockMissionHistory, isLast: true))
    }
    
    func getMissionHistories(page: Int, size: Int, userId: String?, missionType: MissionType, filterType: MissionHistoryFilterType) async -> Result<(data: [UserMissionHistory], isLast: Bool), any Error> {
        .success((data: mockUserMissionHistory, isLast: true))
    }
    
    func getMissionHistoryDetail(missionHistoryId: Int) async -> Result<UserMissionHistoryDetail, Error> {
        .success(.mockData)
    }
    
    func deleteMissionHistory(missionHistoryId: Int) async -> Bool {
        true
    }
    
    func reportMissionHistory(missionHistoryId: Int, reason: String) async throws {
        return
    }
}
