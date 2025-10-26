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
            ForEach(vm.currentMissionHistories, id: \.missionHistoryId) { missionHistory in
                NavigationLink(
                    destination: UserMissionHistoryDetailView(vm: vm, missionHistory: missionHistory)
                ) {
                    UserMissionHistoryItemView(missionHistory: missionHistory)
                }
            }
            
            if vm.hasMorePage {
                ProgressView()
                    .padding(.top, 12)
                    .task {
                        await vm.paginationManager(for: vm.selectedMissionType).loadData(isRefreshing: false)
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
