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
            await vm.loadDataIfNeeded()
        }
        .onChange(of: vm.selectedMissionType) { _, _ in
            vm.closeFilterPicker()
            Task { await vm.loadCurrentData() }
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
        VStack(alignment: .leading, spacing: 0) {
            SelectableTabHeader(
                selectedItem: $vm.selectedMissionType,
                items: MissionType.allCases,
                horizontalPadding: 0,
                height: 44,
                hasBottomLine: true
            )
            
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text("수행한 퀘스트")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray400)
                        .frame(height: 40)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 20)
                    
                    if vm.currentMissionHistories.isEmpty {
                        ErrorView(
                            title: "아직 수행한 퀘스트가 없어요!",
                            subTitle: "내 지역의 퀘스트를\n수행해 보세요",
                            buttonTitle: "퀘스트 바로가기"
                        ) {
                            sharedState.selectedTab = .home
                            dismiss()
                        }
                        .frame(maxWidth: .infinity, minHeight: 600, maxHeight: .infinity, alignment: .center)
                    } else {
                        UserMissionHistoryList(vm: vm)
                            .padding(.top, 24)
                            .padding(.horizontal, 20)
                    }
                }
                .overlay(alignment: .topTrailing) {
                    PickerView(state: vm.filterState, width: 150)
                        .padding(.trailing, 20)
                }
                .zIndex(1)
                .padding(.top, 20)
                .padding(.bottom, 72)
            }
            .scrollDisabled(vm.currentMissionHistories.isEmpty)
        }
    }
}

#Preview {
    UserMissionHistoryView(
        vm: UserMissionHistoryViewModel(
            missionHistoryRepository: MockMissionHistoryRepository()
        )
    )
    .environmentObject(SharedState())
}
