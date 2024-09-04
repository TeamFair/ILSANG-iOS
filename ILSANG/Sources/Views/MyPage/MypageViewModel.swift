//
//  MypageViewModel.swift
//  ILSANG
//
//  Created by Kim Andrew on 6/25/24.
//

import Foundation
import UIKit
import SwiftUI

class MypageViewModel: ObservableObject {
    
    enum ViewStatus {
        case error
        case loading
        case loaded
    }
    
    @Published var viewStatus: ViewStatus = .loading
    @Published var userData: User?
    @Published var challengeList: [Challenge]?
    @Published var questXp: [XPContent]?
    @Published var challengeDelete = false
    @Published var currentIdx: Int = 0
    
    private let userNetwork: UserNetwork
    private let challengeNetwork: ChallengeNetwork
    private let imageNetwork: ImageNetwork
    private let xpNetwork: XPNetwork
    
    private lazy var paginationChallengeManager = PaginationManager<Challenge>(
        size: 10,
        threshold: 3,
        loadPage: { [weak self] page in
            guard let self = self else { return ([], 0) }
            return await self.getQuest(page: page)
        }
    )
   
    private lazy var paginationXPManager = PaginationManager<XPContent>(
        size: 10,
        threshold: 3,
        loadPage: { [weak self] page in
            guard let self = self else { return ([], 0) }
            return await self.getxpLog(page: page)
        }
    )
    
    init(userData: User? = nil, userNetwork: UserNetwork, xpNetwork: XPNetwork, challengeNetwork: ChallengeNetwork, imageNetwork: ImageNetwork) {
        self.userData = userData
        self.userNetwork = userNetwork
        self.xpNetwork = xpNetwork
        self.challengeNetwork = challengeNetwork
        self.imageNetwork = imageNetwork
    }
    
    @MainActor
    func getData() async {
        viewStatus = .loading

        await self.paginationChallengeManager.loadData(isRefreshing: true)
        
        if Task.isCancelled {
            viewStatus = .error
            return
        }
        
        await self.paginationXPManager.loadData(isRefreshing: true)
        
        if Task.isCancelled {
            viewStatus = .error
            return
        }

        viewStatus = .loaded
    }
    
    @MainActor
    func getUser() async {
        let res = await userNetwork.getUser()
        
        switch res {
        case .success(let model):
            self.userData = model.data
            Log(model.data)
            
        case .failure:
            self.userData = nil
            Log(res)
        }
    }
    
    @MainActor
    func getxpLog(page: Int) async -> ([XPContent], Int) {
        let getXpResult = await xpNetwork.getXP(page: page, size: paginationXPManager.size)

        switch getXpResult {
        case .success(let response):
            let xpLogs = response.data

            if page == 0 {
                questXp = xpLogs
            } else {
                if questXp == nil {
                    questXp = []
                }
                questXp! += xpLogs
            }

            return (questXp ?? [], response.total)

        case .failure(let error):
            Log("Error: \(error)")
            return ([], 0)
        }
    }
    
    @MainActor
    func getQuest(page: Int) async -> ([Challenge], Int) {
        let getChallengeResult = await challengeNetwork.getChallenges(page: page)

        switch getChallengeResult {
        case .success(let response):
            let challenges = response.data

            if page == 0 {
                challengeList = challenges
            } else {
                if challengeList == nil {
                    challengeList = []
                }
                challengeList! += challenges
            }

            return (challengeList ?? [], response.total)

        case .failure(let error):
            Log("Error: \(error)")
            return ([], 0)
        }
    }
    
    @MainActor
    func updateChallengeStatus(challengeId: String, ImageId: String) async -> Bool {
        let deleteChallengeRes = await challengeNetwork.deleteChallenge(challengeId: challengeId)
        let deleteImageRes = await imageNetwork.deleteImage(imageId: ImageId)
        
        Log(deleteChallengeRes); Log(deleteImageRes)
        
        return deleteChallengeRes && deleteImageRes
    }
    
    //XP를 레벨로 변경
    func convertXPtoLv(XP: Int) -> Int {
        var totalXP = 0
        var level = 0
        
        while totalXP <= XP {
            level += 1
            totalXP += 50 * level
        }
        
        return level - 1
    }
    
    //이전,다음 레벨 XP
    func xpGapBtwLevels(XP: Int) -> (currentLevelXP: Int, nextLevelXP: Int) {
        let currentLevel = convertXPtoLv(XP: XP)
        let nextLevelXP = 50 * (currentLevel + 1)
        
        var totalXP = 0
        
        for n in 1..<currentLevel + 1 {
            totalXP += 50 * n
        }
        
        return (XP - totalXP, nextLevelXP)
    }
    
    //다음 레벨까지 남은 값
    func xpForNextLv(XP: Int) -> Int {
        let currentLevel = convertXPtoLv(XP: XP)
        let nextLevel = currentLevel + 1
        var totalXP = 0
        
        for n in 1...nextLevel {
            totalXP += 50 * n
        }
        Log(totalXP)
        return totalXP - XP
    }
    
    @MainActor
     func getImage(imageId: String) async -> UIImage? {
        let res = await imageNetwork.getImage(imageId: imageId)
        switch res {
        case .success(let uiImage):
            return uiImage
        case .failure:
            return nil
        }
    }
    
    func ProgressBar(userXP: Int) -> some View {
        let levelData = xpGapBtwLevels(XP: userXP)
        let progress = calculateProgress(userXP: levelData.currentLevelXP, levelXP: levelData.nextLevelXP)
        
        return GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .frame(width: geometry.size.width, height: 8)
                    .cornerRadius(6)
                    .foregroundColor(.gray100)
                
                Rectangle()
                    .frame(width: CGFloat(progress) * geometry.size.width, height: 8)
                    .cornerRadius(6)
                    .foregroundColor(.accentColor)
            }
            .onAppear {
                Log("Progress: \(progress)")
                Log(self.xpGapBtwLevels(XP: userXP).currentLevelXP)
                Log(self.xpGapBtwLevels(XP: userXP).nextLevelXP)
            }
        }
    }
    
    func calculateProgress(userXP: Int, levelXP: Int) -> Double {
        guard levelXP != 0 else { return 0 }
        return Double(userXP) / Double(levelXP)
    }
}

struct MypageViewModelItem: Identifiable {
    var id: UUID
    var status: String
    var nickname: String
    var couponCount: Int
    var completeChallengeCount: Int
    var xpPoint: Int
}
