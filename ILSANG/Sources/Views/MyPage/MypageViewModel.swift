//
//  MypageViewModel.swift
//  ILSANG
//
//  Created by Kim Andrew on 6/25/24.
//

import Foundation

class MypageViewModel: ObservableObject {
    @Published var userData: User?
    @Published var ChallengeList: [Challenge]?
    @Published var questXp: [XP]?
    
    private let userNetwork: UserNetwork
    private let questNetwork: ChallengeNetwork
    private let xpNetwork: XPNetwork
    
    init(userData: User? = nil, userNetwork: UserNetwork, xpNetwork: XPNetwork, questNetwork: ChallengeNetwork) {
        self.userData = userData
        self.userNetwork = userNetwork
        self.xpNetwork = xpNetwork
        self.questNetwork = questNetwork
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
        }
    }
    
    @MainActor
    func getxpLog(userId: String, title: String, page: Int) async {
        let res = await xpNetwork.getXP(userId: userId, title: title, page: page, size: 10)
        
        switch res {
        case .success(let model):
            self.questXp = [model]
            Log(questXp)
            
        case .failure:
            self.questXp = nil
            
        }
    }
    
    @MainActor
    func getQuest(page: Int) async {
        let Data = await questNetwork.getChallenges(page: page)
        
        switch Data {
        case .success(let model):
            self.ChallengeList = model.data
        
        case .failure:
            self.ChallengeList = nil
        }
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
