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
            ForEach(Array(vm.missionHistories.enumerated()), id: \.offset) { idx, missionHistory in
                NavigationLink(destination: UserMissionHistoryDetailView(vm: vm, idx: idx)) {
                    UserMissionHistoryItemView(challenge: missionHistory)
                }
            }
            
            if vm.hasMorePage {
                ProgressView()
                    .padding(.top, 12)
                    .task {
                        await vm.challengePaginationManager.loadData(isRefreshing: false)
                    }
            }
        }
    }
}

#Preview {
    UserMissionHistoryList(
        vm: UserMissionHistoryViewModel(missionHistoryRepository: MockMissionHistoryRepository())
    )
}
