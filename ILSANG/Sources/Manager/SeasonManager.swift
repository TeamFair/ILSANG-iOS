//
//  SeasonManager.swift
//  ILSANG
//
//  Created by Lee Jinhee on 8/25/25.
//


import SwiftUI

@MainActor
final class SeasonManager: ObservableObject {
    @Published var currentSeason: Season?
    @Published var seasons: [Season] = []
    @AppStorage("lastHiddenSeasonNumber") private var lastHiddenSeasonNumber: Int = 0
    private var hasShownPopupThisSession: Bool = false // 현재 세션에서 팝업 확인했는지 여부
    private let seasonNetwork: SeasonNetworkProtocol
    
    init(seasonNetwork: SeasonNetworkProtocol) {
        self.seasonNetwork = seasonNetwork
    }
    
    /// 팝업 표시 여부
    var shouldShowPopup: Bool {
        guard let current = currentSeason else {
            return false
        }
        
        // 현재 세션에서 이미 팝업을 보여줬다면 false
        guard !hasShownPopupThisSession else {
            return false
        }
        
        // 현재 시즌 기간 안에 있고, 다시보지 않기 설정된 시즌 번호가 다른 경우
        return current.containsToday() && current.seasonNumber != lastHiddenSeasonNumber
    }
    
    /// 현재 시즌이 없으면 fetch 후 반환
    func getCurrentSeason() async -> Season? {
        if let current = currentSeason {
            return current
        } else {
            await fetchSeasons()
            return currentSeason
        }
    }
    
    func fetchSeasons() async {
        let result = await seasonNetwork.getSeasons()
        switch result {
        case .success(let res):
            self.seasons = res
            self.currentSeason = res.first(where: { $0.containsToday() })
        case .failure(let err):
            Log(err)
        }
    }
    
    /// "다시 보지 않기" 버튼 활성화 시 호출
    func hidePopupForCurrentSeason() {
        if let current = currentSeason {
            lastHiddenSeasonNumber = current.seasonNumber
        }
    }
    
    /// 팝업을 표시했음을 기록 (세션당 한 번)
    func markPopupAsShown() {
        hasShownPopupThisSession = true
    }
}
