//
//  LegendRankView.swift
//  ILSANG
//
//  Created by Lee Jinhee on 5/16/25.
//

import SwiftUI

struct LegendRankingView: View {
    @StateObject var vm: LegendRankingViewModel
    @Environment(\.dismiss) var dismiss
    private let leadingTrailingColumnWidth: CGFloat = 50
    
    init(titleId: String, titleName: String, titleRepository: TitleRepositoryInterface) {
        self._vm = StateObject(wrappedValue: LegendRankingViewModel(titleId: titleId, titleName: titleName, titleRepository: titleRepository))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            NavigationTitleView(title: "", isSeparatorHidden: true, background: .background) {
                dismiss()
            }
            .padding(.bottom, 8) // 세로로 긴 이미지 대응 (NavigationTitleView의 bottom 패딩과 겹침)
            .overlay {
                HonorIconView(
                    honorTitle: vm.titleName,
                    grade: .legend,
                    imageSize: 18,
                    spacing: 8,
                    font: .init(size: 17, weight: .bold, lineHeight: 22, tracking: 0),
                    fgColor: .gray500
                )
            }
            
            if vm.historyRanks.isEmpty {
                EmptyStateView(message: "해당 칭호를 획득한\n유저가 없어요", fontScale: .big)
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(vm.historyRanks, id: \.userId) { rank in
                            RankingItemView(style: .legendRank(rank))
                        }
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 72)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .background(Color.background)
        .navigationBarBackButtonHidden()
        .task {
            await vm.fetchLegendRanks()
        }
    }
}

#Preview {
    LegendRankingView(titleId: "T001", titleName: "체력왕", titleRepository: TitleRepository(network: TitleNetwork()))
}
