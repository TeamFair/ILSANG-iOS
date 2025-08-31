//
//  SeasonPopupContainerView.swift
//  ILLSANG
//
//  Created by Lee Jinhee on 8/13/25.
//

import SwiftUI

struct SeasonPopupContainerView: View {
    @EnvironmentObject private var manager: SeasonManager
    @State private var isPresented: Bool? = nil
    
    var onTapShowRank: () -> Void
    
    var body: some View {
        let showPopup = isPresented ?? manager.shouldShowPopup
        
        if showPopup, let currentSeason = manager.currentSeason {
            AnimatedPopup(isPresented: Binding(
                get: { self.isPresented ?? true },
                set: { newValue in
                    self.isPresented = false
                }
            )) {
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
                        self.isPresented = false
                    }) { neverShow in
                        withAnimation {
                            if neverShow {
                                manager.hidePopupForCurrentSeason()
                            }
                            isPresented = false
                        }
                        self.isPresented = false
                        onTapShowRank()
                    }
            }
            .onAppear {
                if isPresented == nil {
                    isPresented = true
                }
            }
        }
    }
}
