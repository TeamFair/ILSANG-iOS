//
//  QuestView.swift
//  ILSANG
//
//  Created by Lee Jinhee on 5/19/24.
//

import SwiftUI

struct QuestView: View {
    @StateObject var vm: QuestViewModel = QuestViewModel(questNetwork: QuestNetwork())
    @Namespace private var namespace

    var body: some View {
        VStack(spacing: 0) {
            headerView
                
            if vm.selectedHeader == .uncompleted {
                subHeaderView
            }
            
            switch vm.viewStatus {
            case .loading:
                ProgressView().frame(maxHeight: .infinity)
            case .loaded:
                questListView
            case .error:
                networkErrorView
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.background)
        .sheet(isPresented: $vm.showQuestSheet) {
            questSheetView
                .presentationDetents([.height(558)])
                .presentationDragIndicator(.visible)
        }
        .fullScreenCover(isPresented: $vm.showSubmitRouterView) {
            SubmitRouterView(selectedQuest: vm.selectedQuest)
                .interactiveDismissDisabled()
        }
    }
}

extension QuestView {
    private var headerView: some View {
        HStack(spacing: 15) {
            ForEach(QuestStatus.allCases, id: \.headerText) { status in
                Button {
                    vm.selectedHeader = status
                } label: {
                    Text(status.headerText)
                        .foregroundColor(status == vm.selectedHeader ? .gray500 : .gray300)
                        .font(.system(size: 21, weight: .bold))
                        .frame(height: 30)
                }
            }
            Spacer()
        }
        .frame(height: 50)
        .padding(.horizontal, 20)
    }
    
    private var subHeaderView: some View {
        HStack(spacing: 0) {
            ForEach(XpStat.allCases, id: \.headerText) { xpStat in
                Button {
                    withAnimation(.easeInOut) {
                        vm.selectedXpStat = xpStat
                    }
                } label: {
                    Text(xpStat.headerText)
                        .foregroundColor(xpStat == vm.selectedXpStat ? .gray500 : .gray300)
                        .font(.system(size: 16, weight: xpStat == vm.selectedXpStat ? .semibold : .medium))
                        .frame(height: 30)
                }
                .padding(.horizontal, 6)
                .overlay(alignment: .bottom) {
                    if xpStat == vm.selectedXpStat {
                        Rectangle()
                            .frame(height: 3)
                            .foregroundStyle(.primaryPurple)
                            .matchedGeometryEffect(id: "XpStat", in: namespace)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .overlay(alignment: .bottom) {
            Rectangle()
                .frame(height: 1)
                .foregroundStyle(.gray100)
        }
    }
    
    private var questListView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                switch vm.selectedHeader {
                case .uncompleted:
                    ForEach(vm.uncompletedQuestListByXpStat[vm.selectedXpStat, default: []], id: \.id) { quest in
                        Button {
                            vm.tappedQuestBtn(quest: quest)
                        } label: {
                            QuestItemView(quest: quest, status: .uncompleted)
                        }
                    }
                    
                case .completed:
                    ForEach(vm.itemListByStatus[.completed, default: []], id: \.id) { quest in
                        QuestItemView(quest: quest, status: .completed)
                    }
                    if vm.hasMorePage(status: .completed) {
                        ProgressView()
                            .onAppear {
                                Task {
                                    await vm.completedPaginationManager.loadData(isRefreshing: false)
                                }
                            }
                    }
                }
            }
            .padding(.top, 20)
            .padding(.bottom, 72)
        }
        .frame(maxWidth: .infinity)
        .refreshable {
            await vm.refreshData()
        }
        .overlay {
            if vm.isCurrentListEmpty {
                questListEmptyView
            }
        }
    }
    
    private var questListEmptyView: some View {
        ErrorView(
            title: vm.selectedHeader.emptyTitle,
            subTitle: vm.selectedHeader.emptySubTitle
        ) {
            Task { await vm.loadInitialData() }
        }
    }
    
    private var networkErrorView: some View {
        ErrorView(
            systemImageName: "wifi.exclamationmark",
            title: "네트워크 연결 상태를 확인해주세요",
            subTitle: "네트워크 연결 상태가 좋지 않아\n퀘스트를 불러올 수 없어요 ",
            emoticon: "🥲"
        ) {
            Task { await vm.loadInitialData() }
        }
    }
    
    private var questSheetView: some View {
        VStack(spacing: 0) {
            Text("퀘스트 정보")
                .font(.system(size: 17, weight: .bold))
                .padding(.bottom, 22)
                .padding(.top, 4)
            
            Image(uiImage: vm.selectedQuest.image ?? .logo)
                .resizable()
                .scaledToFill()
                .frame(width: 122, height: 122)
                .clipShape(Circle())
                .padding(.bottom, 20)
            
            Text(vm.selectedQuest.writer)
                .font(.system(size: 15, weight: .regular))
                .padding(.bottom, 5)
            
            Text(vm.selectedQuest.missionTitle)
                .font(.system(size: 18, weight: .bold))
                .padding(.bottom, 18)
            
            Text("+" + String(vm.selectedQuest.totalRewardXP()) + "XP")
                .font(.system(size: 30, weight: .semibold))
                .foregroundStyle(.primaryPurple)
                .padding(.bottom, 19)
            
            StatView(dic: vm.selectedQuest.rewardDic)
                .padding(.bottom, 17)
            
            Text("퀘스트를 수행하셨나요?\n인증 후 포인트를 적립받으세요")
                .font(.system(size: 14, weight: .regular))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
            
            Spacer(minLength: 0)
            
            PrimaryButton(title: "퀘스트 인증하기") {
                vm.tappedQuestApprovalBtn()
            }
        }
        .foregroundStyle(.gray500)
        .padding(20)
    }
}

#Preview {
    QuestView(vm: QuestViewModel(questNetwork: QuestNetwork()))
}

struct StatView: View {
    let columns = [GridItem(.flexible(minimum: 60)), GridItem(.flexible(minimum: 60)), GridItem(.flexible(minimum: 60))]
    let stats: [XpStat] = [.strength, .intellect, .sociability, .charm, .fun]
    let dic: [XpStat: Int]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(stats, id: \.self) { stat in
                HStack {
                    Text("\(stat.headerText) : \(dic[stat] ?? 0)P")
                        .frame(height: 22, alignment: .leading)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.primaryPurple)
                    Spacer(minLength: 0)
                }
                .frame(maxWidth: .infinity)
                .padding(.leading, 8)
            }
        }
        .padding(.horizontal, 12)
        .frame(height: 84)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .foregroundStyle(.primary100.opacity(0.5))
        )
    }
}

#Preview {
    StatView(dic: [.charm: 225, .fun: 392, .sociability: 0])
        .padding(.horizontal, 20)
}
