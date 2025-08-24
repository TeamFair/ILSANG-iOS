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
        case horizontal(case: StyleCase)
        case vertical
        
        enum StyleCase {
            case locationPoint
            case userPoint
            case legend
        }
    }
    
    var body: some View {
        switch style {
        case .horizontal(let style):
            RankingHorizontalItemView(
                rank: rank,
                style: style
            )
        case .vertical:
            RankingVerticalItemView(rank: rank)
        }
    }
}

fileprivate struct RankingHorizontalItemView: View {
    let rank: Rank
    let style: RankingItemView.RankingItemStyle.StyleCase
    
    var body: some View {
        HStack(spacing: 0) {
            RankIconView(idx: rank.idx, size: 26, fontStyle: .heading2)
                .padding(.trailing, 12)

            if [.userPoint, .legend].contains(where: { $0 == style } ) {
                RankProfileImageView(image: rank.profileImage, size: 48)
                    .padding(.trailing, 8)
            }

            VStack(alignment: .leading, spacing: 0) {
                switch style {
                case .locationPoint:
                    Text(rank.nickname)
                        .styledFont(.semibold, size: 13, lineHeight: 20)
                        .foregroundStyle(.gray500)
                        .padding(.bottom, 4)
                    if let xp = rank.xp {
                        Text("\(xp)p")
                            .styledFont(.title1)
                            .foregroundColor(.black)
                    }
                case .userPoint:
                    Text(rank.nickname)
                        .styledFont(.semibold, size: 13, lineHeight: 20)
                        .foregroundStyle(.gray500)
                        .padding(.bottom, 4)
                    
                    titleView
                        .padding(.bottom, 12)
                    
                    if let xp = rank.xp {
                        Text("\(xp)p")
                            .styledFont(.title1)
                            .foregroundColor(.black)
                    }
                case .legend:
                    Text(rank.nickname)
                        .styledFont(.heading2)
                        .foregroundStyle(.black)
                        .padding(.bottom, 4)
                    
                    titleView

                    if let createAt = rank.createdTitleAt {
                        Text("\(createAt.timeAgoCreatedAt()) 획득")
                            .styledFont(.caption1)
                            .foregroundColor(.gray400)
                    }
                }
            }
            
            Spacer(minLength: 0)
            if style == .locationPoint {
                Image(systemName: "chevron.right")
                    .resizable()
                    .scaledToFit()
                    .frame(8)
                    .offset(x: 1)
                    .foregroundStyle(.gray500)
                    .frame(26)
                    .roundedBackground(cornerRadius: 100, bgColor: .background)
                
            }  else if style == .legend {
                TagView(title: "LV.\(XpLevelCalculator.convertXPtoLv(xp: rank.xpTotal))", tagStyle: .level)
            }
        }
        .padding(.leading, style == .legend ? 20 : 36)
        .padding(.trailing, style == .legend ? 20 : 23)
        .padding(.vertical, style == .legend ? 30 : 27)
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
            .padding(.trailing, 8)
        }
    }
    
//    var descriptionView: some View {
//        Group {
//            if let createAt = rank.createdTitleAt {
//                Text("\(createAt.timeAgoCreatedAt()) 획득")
//            } else if let xp = rank.xp {
//                Text("\(xp)p")
//            }
//        }
//        .styledFont(.caption1)
//        .foregroundColor(.gray400)
//    }
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

#Preview {
    VStack {
        RankingItemView(rank: Rank.init(idx: 1, nickname: "gg", xp: 100), style: .horizontal(case: .locationPoint))
        RankingItemView(rank: Rank.init(idx: 1, nickname: "gg", xp: 100), style: .horizontal(case: .userPoint))
        RankingItemView(rank: Rank.init(idx: 3, nickname: "가나다", xp: 1000, xpTotal: 2000, xpType: "FUN", title: "어쩌구 칭호", titleType: .legend, createdTitleAt: "2012.02", profileImageId: "", profileImage: nil), style: .horizontal(case: .legend))
    }
    .padding(.vertical)
    .background(Color.pink)
}
