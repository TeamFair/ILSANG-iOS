//
//  RankingRewardView.swift
//  ILSANG
//
//  Created by Lee Jinhee on 8/24/25.
//

import SwiftUI

struct RankingRewardView: View {
    @StateObject private var viewModel: RankingRewardViewModel
    @Environment(\.layout) var layout
    @Environment(\.dismiss) var dismiss
    
    init(
        titleRepository: TitleRepositoryInterface,
    ) {
        self._viewModel = StateObject(
            wrappedValue: RankingRewardViewModel(
                titleRepository: titleRepository
            )
        )
    }
    
    var body: some View {
        VStack (spacing: 0){
            NavigationTitleView(title: "시즌 보상", isSeparatorHidden: true, background: .background) {
                dismiss()
            }
            .padding(.bottom, 8) // 세로로 긴 이미지 대응 (NavigationTitleView의 bottom 패딩과 겹침)
            
            selectScopeView
            
            switch viewModel.viewStatus {
            case .loading:
                ProgressView().frame(maxHeight: .infinity)
            case .loaded:
                rewardListView
            case .error:
                networkErrorView
            }
        }
        .frame(maxWidth: .infinity)
        .background(Color.background)
        .navigationBarBackButtonHidden()
        .task {
            await viewModel.getRewards(pointType: viewModel.pointType)
        }
        .onChange(of: viewModel.pointType) { _, pointType in
            Task {
                await viewModel.loadRewardsIfNeeded(pointType: pointType)
            }
        }
        .background(Color.background)
    }
    
    private var selectScopeView: some View {
        ScopeHeaderView(
            selectedScope: $viewModel.pointType,
            horizontalPadding: 0,
            height: 44,
            hasBottomLine: true
        )
    }
    
    private var rewardListView: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(viewModel.currentRewards, id: \.titleId) { reward in
                    rewardListItemView(title: reward)
                }
            }
            .padding(.top, 12)
            .padding(.bottom, layout.bottomSpacing)
            .padding(.horizontal, layout.horizontalPadding)
        }
    }
    
    private func rewardListItemView(title: TitleItem) -> some View {
        VStack(spacing: 8) {
            switch title.displayType {
            case .image(let imageName):
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(26)
                    .frame(30)
            case .text(let text):
                Text(text)
                    .styledFont(.heading2)
                    .foregroundStyle(.gray500)
            }
            
            HonorIconView(
                honorTitle: title.name,
                grade: title.grade,
                imageSize: 20,
                spacing: 8,
                font: .init(size: 15, weight: .bold, lineHeight: 20, tracking: 0),
                fgColor: .black
            )
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .roundedBackground(cornerRadius: 16)
    }
    
    private var networkErrorView: some View {
        ErrorView(
            systemImageName: "wifi.exclamationmark",
            title: "네트워크 연결 상태를 확인해주세요",
            subTitle: "네트워크 연결 상태가 좋지 않아\n랭킹을 불러올 수 없어요",
            emoticon: "🥲"
        ) {
            Task {
                await viewModel.getRewards(pointType: viewModel.pointType)
            }
        }
    }
}

#Preview {
    RankingRewardView(
        titleRepository: TitleRepository(
            network: TitleNetwork()
        )
    )
}
