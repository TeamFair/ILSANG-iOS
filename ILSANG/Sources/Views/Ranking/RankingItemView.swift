//
//  RankingItemView.swift
//  ILSANG
//
//  Created by Kim Andrew on 10/7/24.
//

import SwiftUI

struct RankingItemView: View {
    let style: RankingItemStyle
    
    enum RankingItemStyle {
        case totalRank(UserRankItem)
        case userRank(UserRankItem)
        case areaRank(AreaRankItem)
        case currentUserRank(UserRankItem)
        case legendRank(LegendRankItem)
    }
    
    var body: some View {
        switch style {
        case .totalRank(let rank):
            TotalRankItemView(rank: rank)
        case .userRank(let rank):
            UserRankItemView(rank: rank)
        case .areaRank(let rank):
            AreaRankItemView(rank: rank)
        case .currentUserRank(let rank):
            CurrentUserRankItemView(rank: rank)
        case .legendRank(let rank):
            LegendRankItemView(rank: rank)
        }
    }
}

fileprivate struct UserRankItemView: View {
    @ObservedObject var rank: UserRankItem
    
    var body: some View {
        HStack(spacing: 8) {
            RankIconView(idx: rank.rank, size: 26, fontStyle: .heading2)
            RankProfileImageView(image: rank.profileImage, size: 48)
            
            VStack(alignment: .leading, spacing: 0) {
                Text(rank.nickname)
                    .styledFont(.semibold, size: 13, lineHeight: 20)
                    .foregroundStyle(.gray500)
                    .padding(.bottom, 4)
                
                if let title = rank.title {
                    HonorIconView(
                        honorTitle: title.name,
                        grade: HonorGrade(rawValue: title.grade) ?? .standard,
                        imageSize: 12,
                        spacing: 4,
                        font: .badge1,
                        fgColor: .gray400
                    )
                    .padding(.bottom, 12)
                }
                
                Text("\(rank.point)p")
                    .styledFont(.title1)
                    .foregroundColor(.black)
            }
            
            Spacer(minLength: 0)
        }
        .padding(36)
        .roundedBackground(cornerRadius: 16, bgColor: .white)
        .padding(.horizontal, 20)
    }
}

fileprivate struct AreaRankItemView: View {
    let rank: AreaRankItem
    
    var body: some View {
        HStack(spacing: 10) {
            RankIconView(idx: rank.rank, size: 26, fontStyle: .heading2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(rank.areaName)
                    .styledFont(.semibold, size: 13, lineHeight: 20)
                    .foregroundStyle(.gray500)
                
                Text("\(rank.point)p")
                    .styledFont(.title1)
                    .foregroundColor(.black)
            }
            
            Spacer(minLength: 0)
            
            Image(systemName: "chevron.right")
                .resizable()
                .scaledToFit()
                .frame(8)
                .offset(x: 1)
                .foregroundStyle(.gray500)
                .frame(26)
                .roundedBackground(cornerRadius: 100, bgColor: Color.gray92.opacity(0.1))
        }
        .padding(.leading, 36)
        .padding(.trailing, 24)
        .padding(.vertical, 24)
        .roundedBackground(cornerRadius: 16, bgColor: .white)
        .padding(.horizontal, 20)
    }
}

fileprivate struct CurrentUserRankItemView: View {
    @ObservedObject var rank: UserRankItem
    
    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 8) {
                VStack(spacing: 4) {
                    Text("나")
                        .foregroundStyle(.primaryPurple)
                        .font(.system(size: 11))
                        .frame(20)
                        .background(Circle().fill(Color.primary100))
                    RankIconView(idx: rank.rank, size: 26, fontStyle: .heading2)
                }
                RankProfileImageView(image: rank.profileImage, size: 48)
                
                VStack(alignment: .leading, spacing: 0) {
                    Text(rank.nickname)
                        .styledFont(.semibold, size: 13, lineHeight: 20)
                        .foregroundStyle(.gray500)
                        .padding(.bottom, 4)
                    
                    if let title = rank.title {
                        HonorIconView(
                            honorTitle: title.name,
                            grade: HonorGrade(rawValue: title.grade) ?? .standard,
                            imageSize: 12,
                            spacing: 4,
                            font: .badge1,
                            fgColor: .gray400
                        )
                        .padding(.bottom, 12)
                    }
                    
                    Text("\(rank.point)p")
                        .styledFont(.title1)
                        .foregroundColor(.black)
                }
                
                Spacer(minLength: 0)
            }
            
            if let remainPoint = rank.pointGap {
                Text("앞으로 \(remainPoint)P 획득 시 다음 순위로 올라갈 수 있어요!")
                    .styledFont(.badge1)
                    .foregroundColor(.primaryPurple)
                    .padding(.vertical, 6)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.white)
                            .strokeBorder(lineWidth: 1)
                            .foregroundStyle(Color.primaryPurple)
                    )
            }
        }
        .padding(36)
        .roundedBackground(cornerRadius: 16, bgColor: .white)
        .padding(.horizontal, 20)
    }
}

fileprivate struct LegendRankItemView: View {
    let rank: LegendRankItem
    
    var body: some View {
        HStack(spacing: 0) {
            RankIconView(idx: rank.rank, size: 26, fontStyle: .heading2)
                .padding(.trailing, 8)
            
            RankProfileImageView(image: rank.profileImage, size: 48)
                .padding(.trailing, 16)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(rank.nickname)
                    .styledFont(.heading2)
                    .foregroundStyle(.black)
                
                if let title = rank.title {
                    HonorIconView(
                        honorTitle: title.name,
                        grade: title.grade,
                        imageSize: 12,
                        spacing: 4,
                        font: .badge2,
                        fgColor: .gray400
                    )
                }
                
                if let createAt = rank.title?.createdAt {
                    Text("\(createAt.toDisplayFormat(.short)) 획득")
                        .styledFont(.caption1)
                        .foregroundColor(.gray400)
                }
            }
            
            Spacer(minLength: 0)
            
            TagView(title: "LV.\(XpLevelCalculator.convertXPtoLv(xp: rank.point))", tagStyle: .level)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 30)
        .roundedBackground(cornerRadius: 16, bgColor: .white)
        .padding(.horizontal, 20)
    }
}

fileprivate struct TotalRankItemView: View {
    @ObservedObject var rank: UserRankItem
    
    var body: some View {
        VStack(spacing: 6) {
            RankProfileImageView(image: rank.profileImage, size: 64)
            
            RankIconView(idx: rank.rank, size: 24, fontStyle: .tabBold)
            
            VStack(spacing: 2) {
                Text(rank.nickname)
                    .styledFont(.bold, size: 13, lineHeight: 20, tracking: -0.3)
                    .foregroundColor(.black)
                
                if let title = rank.title {
                    HonorIconView(
                        honorTitle: title.name,
                        grade: HonorGrade(rawValue: title.grade) ?? .standard,
                        imageSize: 12,
                        spacing: 4,
                        font: .badge1,
                        fgColor: .gray400
                    )
                }
                Text("\(rank.point)p")
                    .styledFont(.caption1)
                    .foregroundColor(.gray500)
            }
        }
        .frame(width: 150, height: 178)
        .roundedBackground(cornerRadius: 12, bgColor: .white)
    }
}

// MARK: - 재사용 컴포넌트
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
                    .scaledToFit()
            } else {
                Text("\(idx)")
                    .styledFont(fontStyle)
                    .foregroundStyle(.gray500)
            }
        }
        .frame(width: idx < 100 ? size : size + 10, height: size)
    }
}

#Preview {
    VStack {
        RankingItemView(style: .areaRank(.mockData1))
    }
    .padding(.vertical)
    .background(Color.pink)
}
