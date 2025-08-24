//
//  RankingRewardView.swift
//  ILSANG
//
//  Created by Lee Jinhee on 8/24/25.
//

import SwiftUI

struct RankingRewardView: View {
    @Environment(\.dismiss) var dismiss
    @State private var viewStatus: ViewStatus = .loaded
    @State private var selectedScope: PointType = .commercial
    @State var items: [SeasonReward] = [.init(idx: 0, honor: .init(titleId: "", historyId: "", isSelected: false, title: "칭호", acquisitionCondition: "조건", type: .legend), subtitle: "서브타이틀")]
    
    var body: some View {
        VStack (spacing: 0){
            NavigationTitleView(title: "시즌 보상", isSeparatorHidden: true, background: .background) {
                dismiss()
            }
            .padding(.bottom, 8) // 세로로 긴 이미지 대응 (NavigationTitleView의 bottom 패딩과 겹침)
            
            selectScopeView
            
            switch viewStatus {
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
            // TODO: 보상 조회 로직 추가
        }
        .background(Color.background)
    }
    
    
    private var selectScopeView: some View {
        ScopeHeaderView(
            selectedScope: $selectedScope,
            horizontalPadding: 0,
            height: 44,
            hasBottomLine: true
        )
    }
    
    private var rewardListView: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(items, id: \.idx) { reward in
                    rewardListItemView(reward: reward)
                }
            }
            .padding(.top, 12)
            .padding(.bottom, 72)
            .padding(.horizontal, 20)
        }
    }
    struct SeasonReward {
        let idx: Int
        let honor: HonorItem
        let subtitle: String
    }
    
    private func rewardListItemView(reward: SeasonReward) -> some View {
        VStack(spacing: 8) {
            Image(.rank1) // TODO: 이미지 & 텍스트 변경
                .resizable()
                .scaledToFit()
                .frame(30)
            
            HonorIconView(
                honorTitle: reward.honor.title,
                grade: reward.honor.type,
                imageSize: 20,
                spacing: 8,
                font: .init(size: 15, weight: .bold, lineHeight: 20, tracking: 0),
                fgColor: .black
            )
            
            Text(reward.subtitle)
                .styledFont(.regular, size: 13, lineHeight: 16)
                .foregroundStyle(.gray400)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(Color.white)
        .cornerRadius(16)
        
    }
    private var networkErrorView: some View {
        ErrorView(
            systemImageName: "wifi.exclamationmark",
            title: "네트워크 연결 상태를 확인해주세요",
            subTitle: "네트워크 연결 상태가 좋지 않아\n랭킹을 불러올 수 없어요",
            emoticon: "🥲"
        ) {
            Task {
                // TODO: 재시도 로직
            }
        }
    }
}

#Preview {
    RankingRewardView()
}
