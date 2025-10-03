//
//  MyPageHonorManageView.swift
//  ILSANG
//
//  Created by Lee Jinhee on 4/27/25.
//

import SwiftUI

struct MyPageHonorManageView: View {
    @StateObject var vm: MyPageHonorManageViewModel
    @EnvironmentObject var dependencies: AppDependencies
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.dismiss) var dismiss
    private let leadingTrailingColumnWidth: CGFloat = 50
    
    init(dependencies: AppDependencies) {
        _vm = StateObject(
            wrappedValue: MyPageHonorManageViewModel(
                userNetwork: dependencies.userNetwork,
                titleRepository: dependencies.titleRepository
            )
        )
    }
    
    var body: some View {
        VStack(spacing: 0) {
            NavigationTitleView(title: "내 칭호", isSeparatorHidden: true, background: .background) {
                dismiss()
            }
            .padding(.bottom, 8) // 세로로 긴 이미지 대응 (NavigationTitleView의 bottom 패딩과 겹침)
            
            ScrollView {
                VStack(spacing: 0) {
                    honorIntroSection
                    honorGradeTabSection
                    honorListSection
                }
                .padding(.horizontal, 20)
            }
        }
        .frame(maxWidth: .infinity)
        .background(Color.background)
        .navigationBarBackButtonHidden()
        .task {
            await dependencies.honorAcquisitionManager.fetchUnreadHonorHistory()
            await vm.fetchHonors()
        }
        .onDisappear {
            Task {
                await vm.updateHonorIfNeeded()
            }
        }
        .onChange(of: scenePhase, { _, newValue in
            if newValue != .active {
                Task {
                    await vm.updateHonorIfNeeded()
                }
            }
        })
        .overlay {
            if vm.isShowHonorInfoPopup {
                HonorInfoPopupView {
                    vm.closeHonorInfoPopup()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()
                        .animation(.easeOut, value: vm.isShowHonorInfoPopup)
                        .onTapGesture {
                            vm.closeHonorInfoPopup()
                        }
                )
            }
        }
        .overlay(
            Group {
                if let _ = dependencies.honorAcquisitionManager.currentHonor {
                    HonorPopupContainerView()
                }
            }
        )
    }
    
    private var honorIntroSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("칭호")
                    .styledFont(.title1)
                    .foregroundStyle(.black)
                Text("퀘스트를 수행하면서 칭호를 얻을 수 있어요!")
                    .styledFont(.caption1)
                    .foregroundStyle(.gray400)
            }
            Spacer()
            Button {
                vm.showHonorInfoPopup()
            } label: {
                Image(.info)
                    .frame(30)
            }
        }
        .padding(.top, 24)
        .padding(.bottom, 36)
    }
    
    private var honorGradeTabSection: some View {
        MyPageTabView(selectedTab: $vm.selectedHonorGrade)
            .padding(.bottom, 32)
    }
    
    private var honorListSection: some View {
        VStack(spacing: 0) {
            HStack(spacing: 4) {
                Text(vm.selectedHonorGrade.title)
                    .styledFont(.heading3)
                    .foregroundStyle(.black)
                Image(uiImage: vm.selectedHonorGrade.image ?? .init())
                    .resizable()
                    .scaledToFit()
                    .frame(24)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 20)
            
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.gray500)
            
            honorHeaderView
            
            LazyVStack(spacing: 0) {
                ForEach(vm.honors[vm.selectedHonorGrade, default: []], id: \.titleId) { honor in
                    honorListItemView(honor: honor)
                }
            }
            .navigationDestination(isPresented: $vm.showRankingView) {
                if let honor = vm.selectedHonorToShowRanking  {
                    LegendRankingView(titleId: honor.titleId, titleName: honor.name, titleRepository: dependencies.titleRepository)
                }
            }
        }
    }
    
    private func honorListItemView(honor: TitleItem) -> some View {
        HonorListItemView(
            honor: honor,
            rowColumnWidth: leadingTrailingColumnWidth
        ) {
            vm.selectHonor(honor)
        } onShowRankingView: {
            vm.navigateToRankingView(honor: honor)
        }
    }
    
    private var honorHeaderView: some View {
        HStack(spacing: 0) {
            Text("선택")
                .frame(width: leadingTrailingColumnWidth)
            Text("칭호명")
                .frame(maxWidth: .infinity)
            Text("획득조건")
                .frame(maxWidth: .infinity)
            Text("획득")
                .frame(width: leadingTrailingColumnWidth)
        }
        .styledFont(.tabBold)
        .frame(height: 40)
        .foregroundStyle(.gray500)
    }
}

#Preview {
    MyPageHonorManageView(dependencies: AppDependencies())
}
