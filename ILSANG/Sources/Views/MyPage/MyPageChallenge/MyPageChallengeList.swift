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
            
            ScrollView {
                LazyVStack(spacing: 9) {
                    ForEach(Array(vm.challengeList.enumerated()), id: \.offset) { idx, challenge in
                        NavigationLink(destination: ChallengeDetailView(vm: vm, idx: idx)) {
                            challengeListItemView(challenge: challenge)
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
                .padding(.top, 12)
                .padding(.bottom, 72)
            }
            .refreshable {
                await vm.challengePaginationManager.loadData(isRefreshing: true)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay {
            if vm.challengeList.isEmpty {
                EmptyView(title: "수행한 퀘스트가 없어요!")
            }
        }
    }
    
    private func challengeListItemView(challenge: ChallengeViewModelItem) -> some View {
        ZStack {
            Group {
                if let image = challenge.challengeImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    Image(uiImage: .logoWithAlpha)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100)
                }
            }
            .scaledToFill()
            .frame(height: 172)
            .frame(maxWidth: .infinity)
            .overlay(alignment: .bottom) {
                Rectangle()
                    .frame(height: 85)
                    .foregroundStyle(
                        .linearGradient(
                            colors: [.clear, .black.opacity(0.8)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .opacity(challenge.challengeImage == nil ? 0.3 : 1)
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            VStack(alignment: .leading, spacing: 6) {
                Spacer()
                Text(challenge.missionTitle ?? "")
                    .font(.system(size: 23, weight: .bold))
                    .foregroundColor(.white)
                
                Text(challenge.createdAt.timeAgoCreatedAt())
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.gray200)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
        }
    }
}

#Preview {
    MyPageChallengeList(vm: MyPageViewModel(userNetwork: UserNetwork(), challengeNetwork: ChallengeNetwork(), imageNetwork: ImageNetwork(), xpNetwork: XPNetwork()))
}
