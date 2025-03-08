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
        ScrollView {
            LazyVStack(spacing: 9) {
                ForEach(Array(vm.challengeList.enumerated()), id: \.offset) { idx, challenge in
                    NavigationLink {
                        OtherUserChallengeDetailView(challenge: challenge)
                    } label: {
                        ChallengeListItemView(challenge: challenge)
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
        .refreshable {
            await vm.challengePaginationManager.loadData(isRefreshing: true)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay {
            if vm.challengeList.isEmpty {
                EmptyView(title: "수행한 퀘스트가 없어요!")
            }
        }
    }
}

#Preview {
    OtherUserChallengeList(vm: OtherUserProfileViewModel(customerId: "CUS00000000", userNetwork: UserNetwork(), challengeNetwork: ChallengeNetwork(), imageNetwork: ImageNetwork(), xpNetwork: XPNetwork()))
}
