//
//  MyPageInfoView.swift
//  ILSANG
//
//  Created by Kim Andrew on 7/18/24.
//

import SwiftUI

struct MyPageInfoView: View {
    let totalPoint: Int?
    let honorTitle: String?
    
    @State private var touchedIdx: Int? = nil
    private let contentSpacing: CGFloat = 16
    
    var body: some View {
        ScrollView {
            HStack(spacing: contentSpacing) {
                NavigationLink {
                    MyPageHonorManageView()
                } label: {
                    MyPageInfoCardView(
                        title: "내 칭호",
                        content: honorTitle ?? "",
                        showTitleChevron: true,
                        trailContent: HonorTrailingView(hasHonorTitie: honorTitle != nil)
                    )
                }
                
                MyPageInfoCardView(
                    title: "총 포인트",
                    content: "\(String(totalPoint ?? 0).formatNumberInText())XP",
                    trailContent: TotalXpTrailingView()
                )
            }
        }
        .scrollIndicators(.never)
    }
}

#Preview {
    MyPageInfoView(
        totalPoint: 0, honorTitle: "세상을 움직이는 자"
    )
}
