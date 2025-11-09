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
            ForEach(Array(vm.currentItems.enumerated()), id: \.element.missionHistoryId) { index, missionHistory in
                NavigationLink(
                    destination: UserMissionHistoryDetailView(vm: vm, missionHistory: missionHistory)
                ) {
                    UserMissionHistoryItemView(missionHistory: missionHistory)
                        .task { await vm.loadMoreDataIfNeeded(at: index ) }
                }
            }
            
            LoadMoreIndicatorView(isVisible: vm.canLoadMore)
        }
    }
}

#Preview {
    UserMissionHistoryList(
        vm: UserMissionHistoryViewModel(missionHistoryRepository: MockMissionHistoryRepository())
    )
}
