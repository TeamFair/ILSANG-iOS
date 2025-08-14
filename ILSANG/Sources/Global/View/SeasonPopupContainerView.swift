//
//  SeasonPopupContainerView.swift
//  ILLSANG
//
//  Created by Lee Jinhee on 8/13/25.
//

import SwiftUI

struct SeasonPopupContainerView: View {
    @EnvironmentObject private var manager: SeasonManager
    @State private var isPresented = false
    
    var onTapShowRank: () -> Void
    
    var body: some View {
        if manager.shouldShowPopup, let currentSeason = manager.currentSeason {
            AnimatedPopup(isPresented: $isPresented) {
                SeasonOpenPopup(
                    season: currentSeason.seasonNumber,
                    seasonStartDate: currentSeason.startDate,
                    seasonEndDate: currentSeason.endDate,
                    onDismiss: { neverShow in
                        withAnimation {
                            if neverShow {
                                manager.hidePopupForCurrentSeason()
                            }
                            isPresented = false
                        }
                    }) { neverShow in
                        withAnimation {
                            if neverShow {
                                manager.hidePopupForCurrentSeason()
                            }
                            isPresented = false
                        }
                        onTapShowRank()
                    }
            }
            .onAppear {
                isPresented = true
            }
        }
    }
}


@MainActor
final class SeasonManager: ObservableObject {
    @Published private(set) var currentSeason: Season?
    private var seasons: [Season] = []
    @AppStorage("lastHiddenSeasonNumber") private var lastHiddenSeasonNumber: Int = 0
    
    private let seasonNetwork: SeasonNetworkProtocol
    
    init(seasonNetwork: SeasonNetworkProtocol) {
        self.seasonNetwork = seasonNetwork
        
        Task {
            await fetchSeasons()
        }
    }
    
    /// 팝업 표시 여부
    var shouldShowPopup: Bool {
        guard let current = currentSeason else {
            return false
        }
        // 현재 시즌 기간 안에 있고, 다시보지 않기 설정된 시즌 번호가 다른 경우
        return current.containsToday() && current.seasonNumber != lastHiddenSeasonNumber
    }
    
    func fetchSeasons() async {
        let result = await seasonNetwork.getSeasons()
        switch result {
        case .success(let res):
            self.seasons = res.data
            self.currentSeason = res.data.first(where: { $0.containsToday() })
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
}



#Preview {
    @Previewable @StateObject var seasonManager = SeasonManager(seasonNetwork: MockSeasonNetwork())
    
    SeasonPopupContainerView(onTapShowRank: {})
        .environmentObject(seasonManager)
    
}
