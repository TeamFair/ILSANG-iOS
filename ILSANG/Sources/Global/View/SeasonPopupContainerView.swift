//
//  SeasonPopupContainerView.swift
//  ILLSANG
//
//  Created by Lee Jinhee on 8/13/25.
//

import SwiftUI

struct SeasonPopupContainerView: View {
    @EnvironmentObject var dependencies: AppDependencies
    @State private var isPresented: Bool = false
    var onTapShowRank: () -> Void
    
    var body: some View {
        ZStack {
            if isPresented, let currentSeason = dependencies.seasonManager.currentSeason {
                AnimatedPopup(isPresented: $isPresented) {
                    SeasonOpenPopup(
                        season: currentSeason.seasonNumber,
                        seasonStartDate: currentSeason.startDate,
                        seasonEndDate: currentSeason.endDate,
                        onDismiss: { neverShow in
                            if neverShow {
                                dependencies.seasonManager.hidePopupForCurrentSeason()
                            }
                            withAnimation(.smooth) {
                                isPresented = false
                            }
                        },
                        onConfirm: { neverShow in
                            if neverShow {
                                dependencies.seasonManager.hidePopupForCurrentSeason()
                            }
                            withAnimation(.smooth) {
                                isPresented = false
                            }
                            onTapShowRank()
                        }
                    )
                }
            }
        }
        .task {
            // 로그인 직후 currentSeason이 없으면 fetch
            if dependencies.seasonManager.seasons.isEmpty {
                _ = await dependencies.seasonManager.getCurrentSeason()
            }
            
            // fetch 완료 후 팝업 조건 체크
            if dependencies.seasonManager.shouldShowPopup {
                dependencies.seasonManager.markPopupAsShown()
                isPresented = true
            }
        }
    }
}
