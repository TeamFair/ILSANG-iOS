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
    
    init(honorId: String, honorName: String) {
        self._vm = StateObject(wrappedValue: LegendRankingViewModel(honorId: honorId, honorName: honorName, honorNetwork: HonorNetwork()))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            NavigationTitleView(title: "", isSeparatorHidden: true, background: .background) {
                dismiss()
            }
            .padding(.bottom, 8) // 세로로 긴 이미지 대응 (NavigationTitleView의 bottom 패딩과 겹침)
            .overlay {
                HonorIconView(
                    honorTitle: vm.honorName,
                    grade: .legend,
                    imageSize: 18,
                    spacing: 8,
                    font: .init(size: 17, weight: .bold, lineHeight: 22, tracking: 0),
                    fgColor: .gray500
                )
            }
            
            if vm.historyRanks.isEmpty {
                EmptyView(title: "해당 칭호를 획득한\n유저가 없어요")
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(Array(vm.historyRanks.enumerated()), id: \.offset) { idx, rank in
                            RankingItemView(rank: rank.toRank(idx: idx+1), style: .horizontal)
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
    LegendRankingView(honorId: "TQ00030", honorName: "체력왕")
}

struct HistoryRankViewModelItem {
    let xpPoint: Int
    let nickname: String
    let title: String?
    let titleType: HonorGrade?
    let createdAt: String
    let profileImageId: String?
    let profileImage: UIImage?
   
    init(xpPoint: Int, nickname: String, title: String?, titleType: HonorGrade?, createdAt: String, profileImageId: String?, profileImage: UIImage?) {
        self.xpPoint = xpPoint
        self.nickname = nickname
        self.title = title
        self.titleType = titleType
        self.createdAt = createdAt
        self.profileImageId = profileImageId
        self.profileImage = profileImage
    }
    
    static func make(from historyRank: HistoryRank) async -> HistoryRankViewModelItem {
        let profileImage: UIImage?
        if let imageId = historyRank.customer.profileImage {
            profileImage = await ImageCacheService.shared.loadImageAsync(imageId: imageId)
        } else {
            profileImage = nil
        }
        
        return HistoryRankViewModelItem(
            xpPoint: historyRank.customer.xpPoint,
            nickname: historyRank.customer.nickname,
            title: historyRank.customer.title?.name,
            titleType: historyRank.customer.title.flatMap { HonorGrade(rawValue: $0.type) },
            createdAt: historyRank.titleHistory.createdAt,
            profileImageId: historyRank.customer.profileImage,
            profileImage: profileImage
        )
    }
}
