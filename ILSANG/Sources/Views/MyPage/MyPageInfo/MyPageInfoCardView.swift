//
//  MyPageInfoCardView.swift
//  ILSANG
//
//  Created by Lee Jinhee on 1/10/25.
//

import SwiftUI

struct MyPageInfoCardView<TrailContent: View>: View {
    let title: String
    let content: String
    var showTitleChevron: Bool = false
    let trailContent: TrailContent
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 2) {
                Text(title)
                    .styledFont(.caption2)
                Image(systemName: "chevron.right")
                    .styledFont(.caption2)
                    .frame(14)
                    .opacity(showTitleChevron ? 1 : 0)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundColor(.gray400)
            
            Text(content)
                .styledFont(.title2)
                .foregroundColor(.gray500)
            
            Spacer(minLength: 0)
            
            trailContent
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .frame(height: 170)
        .background(.white)
        .cornerRadius(12)
    }
}

#Preview {
    VStack {
        MyPageInfoCardView(
            title: "총 포인트",
            content: "1000XP",
            trailContent:
                Image(.xpGraph)
        )
    }
    .padding()
    .background(Color.background)
}
