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
