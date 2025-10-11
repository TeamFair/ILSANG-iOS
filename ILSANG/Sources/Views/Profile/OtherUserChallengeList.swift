//
//  OtherUserChallengeList.swift
//  ILSANG
//
//  Created by Lee Jinhee on 3/8/25.
//

import SwiftUI

struct OtherUserChallengeList: View {
    @ObservedObject var vm: OtherUserProfileViewModel
    
    var body: some View {
        if vm.challengeList.isEmpty {
            ErrorView(
                title: "완료된 퀘스트가 없어요",
                subTitle: "사용자가 아직 퀘스트를\n수행하지 않았어요",
                showButton: false
            )
            .frame(minHeight: 353)
        } else {
            LazyVStack(spacing: 9) {
                ForEach(vm.challengeList, id: \.missionHistoryId) { challenge in
                    NavigationLink {
                        OtherUserChallengeDetailView(challenge: challenge)
                    } label: {
                        UserMissionHistoryItemView(challenge: challenge)
                    }
                }
                
                if vm.hasMorePage() {
                    ProgressView()
                        .padding(.top, 12)
                        .task {
                            await vm.challengePaginationManager.loadData(isRefreshing: false)
                        }
                }
            }
            .padding(.bottom, 72)
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
