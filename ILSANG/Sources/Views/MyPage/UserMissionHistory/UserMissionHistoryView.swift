//
//  UserMissionHistoryView.swift
//  ILLSANG
//
//  Created by Lee Jinhee on 8/28/25.
//

import SwiftUI

struct UserMissionHistoryView: View {
    @StateObject var vm: UserMissionHistoryViewModel
    @EnvironmentObject var sharedState: SharedState
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            header
            content
        }
        .background(Color.background)
        .navigationBarBackButtonHidden(true)
        .task {
            if vm.missionHistories.isEmpty {
                await vm.challengePaginationManager.loadData(isRefreshing: true)
            }
        }
    }
    
    private var header: some View {
        NavigationTitleView(title: "수행한 퀘스트", isSeparatorHidden: true, background: .background) {
            dismiss()
        }
        .padding(.bottom, 8) // 세로로 긴 이미지 대응
    }
    
    @ViewBuilder
    private var content: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("수행한 챌린지")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.gray400)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 20)
                .padding(.leading, 20)
            
            if vm.missionHistories.isEmpty {
                ErrorView(
                    title: "아직 수행한 퀘스트가 없어요!",
                    subTitle: "내 지역의 퀘스트를\n수행해 보세요",
                    buttonTitle: "퀘스트 바로가기"
                ) {
                    sharedState.selectedTab = .home
                    dismiss()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            } else {
                ScrollView {
                    UserMissionHistoryList(vm: vm)
                        .padding(.top, 20)
                        .padding(.horizontal, 20)
                }
            }
        }
    }
}

#Preview {
    UserMissionHistoryView(
        vm: UserMissionHistoryViewModel(
            missionHistoryRepository: MissionHistoryRepository(
                network: MissionHistoryNetwork()
            )
        )
    )
}
