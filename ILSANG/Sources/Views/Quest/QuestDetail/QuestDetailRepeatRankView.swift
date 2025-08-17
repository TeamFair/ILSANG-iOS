//
//  QuestDetailRepeatRankView.swift
//  ILSANG
//
//  Created by Lee Jinhee on 4/4/25.
//

import SwiftUI

struct QuestDetailRepeatRankView: View {
    let rank: Int?
    let contentWidth: CGFloat
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("나의 랭킹")
                .styledFont(.badge1)
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                .foregroundStyle(.white)
                .background(Color.primaryPurple)
                .clipShape(Capsule())
            
            HStack {
                if let rank, rank != 0 {
                    if rank <= 3 {
                        Image("rank\(rank)")
                    }
                    Text("\(rank)위")
                } else {
                    Text("-")
                }
            }
            .foregroundStyle(.primaryPurple)
            .styledFont(.bold, size: 24, lineHeight: 34)
            .frame(height: contentWidth, alignment: .top)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
    }
}

#Preview {
    VStack(spacing: 12) {
        QuestDetailRepeatRankView(rank: nil, contentWidth: 100)
        QuestDetailRepeatRankView(rank: 1, contentWidth: 100)
        QuestDetailRepeatRankView(rank: 2, contentWidth: 100)
        QuestDetailRepeatRankView(rank: 3, contentWidth: 100)
        QuestDetailRepeatRankView(rank: 4, contentWidth: 100)
    }
    .padding()
    .background(Color.gray100)
}
