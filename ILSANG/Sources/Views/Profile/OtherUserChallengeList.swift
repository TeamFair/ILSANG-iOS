//
//  OtherUserChallengeList.swift
//  ILSANG
//
//  Created by Lee Jinhee on 3/8/25.
//

import SwiftUI

struct OtherUserChallengeList: View {
    @ObservedObject var vm: OtherUserProfileViewModel
    @Environment(\.layout) var layout
    
    var body: some View {
        switch vm.missionHistoryViewStatus {
        case .error:
            EmptyView() // TODO: 변경
        case .loading: // page 0을 불러올 때만 프로그레스뷰 표시
            ProgressView().frame(maxWidth: .infinity, minHeight: 300)
        case .loaded:
            if vm.isCurrentListEmpty {
                ErrorView(
                    title: "완료된 퀘스트가 없어요",
                    subTitle: "사용자가 아직 퀘스트를\n수행하지 않았어요",
                    showButton: false
                )
                .frame(minHeight: 353)
            } else {
                LazyVStack(spacing: 9) {
                    ForEach(Array(vm.currentItems.enumerated()), id: \.1.missionHistoryId) { index, missionHistory in
                        NavigationLink {
                            OtherUserChallengeDetailView(vm: vm, missionHistory: missionHistory)
                        } label: {
                            UserMissionHistoryItemView(missionHistory: missionHistory)
                                .task {
                                    await vm.loadMoreDataIfNeeded(at: index)
                                }
                        }
                    }
                    
                    LoadMoreIndicatorView(isVisible: vm.canLoadMore)
                }
                .padding(.bottom, layout.bottomSpacing)
                .frame(minHeight: 300, alignment: .top)
            }
        }
    }
}

#Preview {
    OtherUserChallengeList(
        vm: OtherUserProfileViewModel(
            userId: "CUS00000000",
            userRepository: UserRepository(network: UserNetwork()),
            missionHistoryRepository: MissionHistoryRepository(network: MissionHistoryNetwork()), areaNameService: AreaNameService(areaRepository: AreaRepository(network: AreaNetwork())),
            seasonManager: SeasonManager(seasonNetwork: SeasonNetwork())
        )
    )
}
