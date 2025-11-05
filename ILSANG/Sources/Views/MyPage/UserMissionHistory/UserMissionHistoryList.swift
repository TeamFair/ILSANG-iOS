//
//  UserMissionHistoryList.swift
//  ILSANG
//
//  Created by Kim Andrew on 5/22/24.
//

import SwiftUI

struct UserMissionHistoryList: View {
    @ObservedObject var vm: UserMissionHistoryViewModel
    
    var body: some View {
        LazyVStack(spacing: 9) {
            ForEach(Array(vm.currentMissionHistories.enumerated()), id: \.1.missionHistoryId) { index, missionHistory in
                NavigationLink(
                    destination: UserMissionHistoryDetailView(vm: vm, missionHistory: missionHistory)
                ) {
                    UserMissionHistoryItemView(missionHistory: missionHistory)
                        .task { await vm.loadMoreDataIfNeeded(index: index ) }
                }
            }
            
            if vm.hasMorePage {
                ProgressView()
                    .padding(.top, 12)
            }
        }
    }
}

#Preview {
    UserMissionHistoryList(
        vm: UserMissionHistoryViewModel(missionHistoryRepository: MockMissionHistoryRepository())
    )
}
