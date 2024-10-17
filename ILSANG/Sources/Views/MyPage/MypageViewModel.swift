//
//  MypageViewModel.swift
//  ILSANG
//
//  Created by Kim Andrew on 6/25/24.
//

import Foundation
import UIKit
import SwiftUI

struct MypageViewModelItem: Identifiable {
    var id: UUID
    var status: String
    var nickname: String
    var couponCount: Int
    var completeChallengeCount: Int
    var xpPoint: Int
}

class MypageViewModel: ObservableObject {
    @Published var userData: User?
    @Published var challengeList: [Challenge]?
    @Published var xpStats: [XpStat: Int]
    @Published var questXp: [XPContent]?
    @Published var challengeDelete = false
    
    private let userNetwork: UserNetwork
    private let challengeNetwork: ChallengeNetwork
    private let imageNetwork: ImageNetwork
    private let xpNetwork: XPNetwork
    
    init(userData: User? = nil, challengeList: [Challenge]? = nil, xpStats: [XpStat: Int] = [:], questXp: [XPContent]? = nil, challengeDelete: Bool = false, userNetwork: UserNetwork, challengeNetwork: ChallengeNetwork, imageNetwork: ImageNetwork, xpNetwork: XPNetwork) {
        self.userData = userData
        self.challengeList = challengeList
        self.xpStats = xpStats
        self.questXp = questXp
        self.challengeDelete = challengeDelete
        self.userNetwork = userNetwork
        self.challengeNetwork = challengeNetwork
        self.imageNetwork = imageNetwork
        self.xpNetwork = xpNetwork
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
    func getxpLog(page: Int, size: Int) async {
        let res = await xpNetwork.getXP(page: page, size: 10)
        
        switch res {
        case .success(let model):
            self.questXp = model.data
            Log(questXp)
            
        case .failure:
            self.questXp = nil
            Log(res)
        }
    }
    
    @MainActor
    func getXpStat() async {
        let res = await xpNetwork.getXpStats()
        
        switch res {
        case .success(let model):
            let xpData = model.data
            self.xpStats = [
                .strength: xpData.strengthStat,
                .intellect: xpData.intellectStat,
                .fun: xpData.funStat,
                .charm: xpData.charmStat,
                .sociability: xpData.sociabilityStat
            ]
            Log(xpStats)
            
        case .failure:
            self.xpStats = [:]
        }
    }
    
    @MainActor
    func getQuest(page: Int) async {
        let Data = await challengeNetwork.getChallenges(page: page)
        
        switch Data {
        case .success(let model):
            self.challengeList = model.data
            Log(self.challengeList)

        case .failure:
            self.challengeList = nil
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
        
        return max(0, level - 1)
    }
    
    //이전,다음 레벨 XP
    func xpGapBtwLevels(XP: Int) -> (currentLevelXP: Int, nextLevelXP: Int) {
        let sanitizedXP = max(0, XP)
        
        let currentLevel = convertXPtoLv(XP: sanitizedXP)
        let nextLevelXP = 50 * (currentLevel + 1)
        
        var totalXP = 0
        
        if currentLevel > 0 {
            for n in 1..<currentLevel + 1 {
                totalXP += 50 * n
            }
        }
        
        return (sanitizedXP - totalXP, nextLevelXP)
    }
    
    //다음 레벨까지 남은 값 
    func xpForNextLv(XP: Int) -> Int {
        let sanitizedXP = max(0, XP)
        let currentLevel = convertXPtoLv(XP: sanitizedXP)
        let nextLevel = currentLevel + 1
        var totalXP = 0
        
        for n in 1...nextLevel {
            totalXP += 50 * n
        }
        
        Log(totalXP)
        return totalXP - sanitizedXP
    }
    
    func getImage(imageId: String) async -> UIImage? {
        await ImageCacheService.shared.loadImageAsync(imageId: imageId)
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
