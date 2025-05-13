//
//  MyPageQuestList.swift
//  ILSANG
//
//  Created by Kim Andrew on 5/22/24.
//

import SwiftUI

struct MyPageChallengeList: View {
    @ObservedObject var vm: MyPageViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("수행한 챌린지")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.gray400)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVStack(spacing: 9) {
                ForEach(Array(vm.challengeList.enumerated()), id: \.offset) { idx, challenge in
                    NavigationLink(destination: ChallengeDetailView(vm: vm, idx: idx)) {
                        ChallengeListItemView(challenge: challenge)
                    }
                }
                
                if vm.hasMorePage(for: .challenge) {
                    ProgressView()
                        .padding(.top, 12)
                        .task {
                            await vm.challengePaginationManager.loadData(isRefreshing: false)
                        }
                }
            }
            .frame(maxWidth: .infinity, minHeight: 400, maxHeight: .infinity)
        }
        .overlay {
            if vm.challengeList.isEmpty {
                EmptyView(title: "수행한 퀘스트가 없어요!")
            }
        }
    }
}

#Preview {
    MyPageChallengeList(vm: MyPageViewModel(userNetwork: UserNetwork(), challengeNetwork: ChallengeNetwork(), imageNetwork: ImageNetwork(), xpNetwork: XPNetwork()))
}
