//
//  RankingItemView.swift
//  ILSANG
//
//  Created by Kim Andrew on 10/7/24.
//

import SwiftUI

struct RankingItemView: View {
    let rank: Rank
    let style: RankingItemStyle
    
    enum RankingItemStyle {
        case horizontal
        case vertical
    }
    
    var body: some View {
        switch style {
        case .horizontal:
            RankingHorizontalItemView(rank: rank)
        case .vertical:
            RankingVerticalItemView(rank: rank)
        }
    }
}

fileprivate struct RankingHorizontalItemView: View {
    let rank: Rank
    
    var body: some View {
        HStack(spacing: 0) {
            RankIconView(idx: rank.idx, size: 26, fontStyle: .heading2)

            RankProfileImageView(image: rank.profileImage, size: 48)
                .padding(.leading, 8)
                .padding(.trailing, 16)
            
            VStack (alignment: .leading, spacing: 6) {
                Text(rank.nickname)
                    .styledFont(.heading2)
                    .foregroundStyle(.black)
                
                titleView
                
                descriptionView
            }
            
            Spacer(minLength: 0)
            
            TagView(title: "LV.\(XpLevelCalculator.convertXPtoLv(xp: rank.xpTotal))", tagStyle: .level)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 30)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(.white)
        .cornerRadius(16)
        .padding(.horizontal, 20)
    }
    
    @ViewBuilder
    var titleView: some View {
        if let title = rank.title, let honorTypeImage = rank.titleType?.image {
            HStack(spacing: 4) {
                Image(uiImage: honorTypeImage)
                    .resizable()
                    .frame(12)
                Text(title)
                    .styledFont(.badge1)
                    .foregroundStyle(.gray400)
            }
        }
    }
    
    var descriptionView: some View {
        Group {
            if let createAt = rank.createdTitleAt {
                Text("\(createAt.timeAgoCreatedAt()) 획득")
            } else if let xp = rank.xp {
                if let xpType = rank.xpType {
                    Text("\(convertStat(xpType)) : \(xp)p")
                } else {
                    Text("\(xp)p")
                }
            }
        }
        .styledFont(.caption1)
        .foregroundColor(.gray400)
    }
}

extension RankingHorizontalItemView {
    /// XpStat 한글 변환
    func convertStat(_ xpType: String) -> String {
        let typeMapping: [String: String] = [
            "STRENGTH": "체력",
            "INTELLECT": "지능",
            "FUN": "재미",
            "CHARM": "매력",
            "SOCIABILITY": "사회성"
        ]
    
        return typeMapping[xpType] ?? xpType
    }
}

fileprivate struct RankingVerticalItemView: View {
    let rank: Rank
    
    var body: some View {
        VStack(spacing: 6) {
            RankProfileImageView(image: rank.profileImage, size: 64)
                .padding(6)
            
            RankIconView(idx: rank.idx, size: 24, fontStyle: .tabBold)
            
            Text(rank.nickname)
                .styledFont(.bold, size: 13, lineHeight: 20, tracking: -0.3)
                .foregroundColor(.black)
                .padding(.bottom, -4)
            
            if let xp = rank.xp {
                Text("\(xp)xp")
                    .styledFont(.caption1)
                    .foregroundColor(.gray500)
            }
        }
        .frame(width: 150)
        .padding(.vertical, 16)
        .background(.white)
        .cornerRadius(12)
    }
}

fileprivate struct RankProfileImageView: View {
    let image: UIImage?
    let size: CGFloat
    var emoji: String = "😍"

    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
            } else {
                Text(emoji)
                    .font(.system(size: size * 0.5))
            }
        }
        .frame(width: size, height: size)
        .background(Color.backgroundBlue)
        .clipShape(Circle())
    }
}

fileprivate struct RankIconView: View {
    let idx: Int
    let size: CGFloat
    let fontStyle: FontStyle
    
    var body: some View {
        Group {
            if idx <= 3 {
                Image("rank\(idx)")
                    .resizable()
            } else {
                Text("\(idx)")
                    .styledFont(fontStyle)
                    .foregroundStyle(.gray500)
            }
        }
        .frame(width: size, height: size)
    }
}
