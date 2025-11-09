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
    @Environment(\.layout) var layout
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            navigationTitle
            missionTypeTabHeader
            missionHistoryList
        }
        .background(Color.background)
        .navigationBarBackButtonHidden(true)
        .task {
            await vm.loadDataIfNeeded()
        }
        .onChange(of: vm.selectedMissionType) { _, _ in
            vm.closeFilterPicker()
            Task { await vm.loadDataIfNeeded() }
        }
    }
    
    private var navigationTitle: some View {
        NavigationTitleView(title: "수행한 퀘스트", isSeparatorHidden: true, background: .background) {
            dismiss()
        }
        .padding(.bottom, 8) // 세로로 긴 이미지 대응
    }
    
    private var missionTypeTabHeader: some View {
        SelectableTabHeader(
            selectedItem: $vm.selectedMissionType,
            items: MissionType.allCases,
            horizontalPadding: 0,
            height: 44,
            hasBottomLine: true
        )
    }
    
    private var missionHistoryList: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("수행한 퀘스트")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray400)
                    .frame(height: 40)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, layout.horizontalPadding)
                
                switch vm.viewStatus {
                case .loading:
                    ProgressView()
                        .frame(maxWidth: .infinity, minHeight: 500, maxHeight: .infinity)
                case .loaded:
                    if vm.isCurrentListEmpty {
                        listEmptyView
                    } else {
                        UserMissionHistoryList(vm: vm)
                            .padding(.top, 24)
                            .padding(.horizontal, layout.horizontalPadding)
                    }
                case .error:
                    networkErrorView
                }
            }
            .overlay(alignment: .topTrailing) {
                PickerView(state: vm.filterState, width: 150)
                    .padding(.trailing, layout.horizontalPadding)
            }
            .zIndex(1)
            .padding(.top, 20)
            .padding(.bottom, layout.bottomSpacing)
        }
        .scrollDisabled(vm.currentItems.isEmpty)
    }
    
    private var listEmptyView: some View {
        ErrorView(
            title: "아직 수행한 퀘스트가 없어요!",
            subTitle: "내 지역의 퀘스트를\n수행해 보세요",
            buttonTitle: "퀘스트 바로가기"
        ) {
            sharedState.selectedTab = .home
            dismiss()
        }
        .frame(maxWidth: .infinity, minHeight: 600, maxHeight: .infinity, alignment: .center)
    }
    
    private var networkErrorView: some View {
        ErrorView(
            systemImageName: "wifi.exclamationmark",
            title: "네트워크 연결 상태를 확인해주세요",
            subTitle: "네트워크 연결 상태가 좋지 않아\n퀘스트를 불러올 수 없어요",
            emoticon: "🥲"
        ) {
            Task { await vm.loadDataIfNeeded() }
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
