//
//  IllsangZonePointView.swift
//  ILSANG
//
//  Created by Lee Jinhee on 8/28/25.
//


import SwiftUI

struct IllsangZonePointView: View {
    let topCommercialArea: TopCommercialAreaItem
    let totalOwnerContributions: [TotalOwnerContributionItem]
    let showPrimaryButton: Bool
    var onTap: (() -> Void)? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("일상존 점수")
                .styledFont(.heading2)
                .foregroundColor(.black)
                .padding(.bottom, 24)
            
            HStack(alignment: .top, spacing: 20) {
                Image(.rewardCommecial)
                    .resizable()
                    .frame(66)
                
                if let commercialAreaName = topCommercialArea.commercialAreaName {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(commercialAreaName)
                            .styledFont(.title2)
                            .foregroundColor(.black)
                        Text("\(topCommercialArea.point)P")
                            .styledFont(.title1)
                            .foregroundColor(.primary500)
                            .padding(.bottom, 4)
                        Text("\(commercialAreaName) 전체 기여자 중 \(topCommercialArea.ownerContributionPercent)%를 기여했어요!")
                            .styledFont(.caption2)
                            .foregroundColor(.gray400)
                    }
                }
                
                Spacer(minLength: 0)
            }
            
            if showPrimaryButton {
                PrimaryButton(
                    title: "퀘스트 바로가기",
                    action: { onTap?() }
                )
                .padding(.top, 24)
            }
            
            if totalOwnerContributions.count > 0 {
                Text("많이 기여한 일상존")
                    .styledFont(.heading2)
                    .foregroundColor(.black)
                    .padding(.top, 48)
                    .padding(.bottom, 24)
                
                VStack(alignment: .leading, spacing: 32) {
                    let percents = totalOwnerContributions.pointRatios()
                    
                    ForEach(Array(totalOwnerContributions.enumerated()), id: \.offset) { idx, contribution in
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(spacing: 4) {
                                let rankStyle = RankStyle(rank: idx+1)
                                Text("\(idx+1)")
                                    .styledFont(.semibold, size: 13, lineHeight: 13)
                                    .foregroundColor(.white)
                                    .frame(18)
                                    .background(
                                        Circle()
                                            .fill(rankStyle.backgroundColor)
                                            .strokeBorder(lineWidth: 1)
                                            .foregroundStyle(rankStyle.strokeColor)
                                    )
                                Text(contribution.commercialAreaName ?? "")
                                    .styledFont(.bold, size: 13, lineHeight: 20, tracking: -0.3)
                                    .foregroundColor(.black)
                                Spacer(minLength: 0)
                                Text("\(percents[idx])%")
                                    .styledFont(.tabBold)
                                    .foregroundColor(.primaryPurple)
                                Text("\(contribution.point)P")
                                    .styledFont(.caption2)
                                    .foregroundColor(.gray400)
                            }
                            
                            ProgressBar(progress: Double(percents[idx]), height: 12)
                        }
                    }
                }
            }
        }
        .padding(16)
        .roundedBackground(cornerRadius: 12, bgColor: .white)
    }
    
    enum RankStyle {
        case first
        case second
        case third
        case other
        
        var backgroundColor: Color {
            switch self {
            case .first: return .rank1Background
            case .second: return .gray100
            case .third: return .rank3Background
            case .other: return .clear
            }
        }
        
        var strokeColor: Color {
            switch self {
            case .first: return .rank1Stroke
            case .second: return .gray300
            case .third: return .rank3Stroke
            case .other: return .clear
            }
        }
        
        init(rank: Int) {
            switch rank {
            case 1: self = .first
            case 2: self = .second
            case 3: self = .third
            default: self = .other
            }
        }
    }
}


#Preview {
    ScrollView {
        IllsangZonePointView(
            topCommercialArea: .init(commercialAreaCode: "S01", commercialAreaName: "서현", point: 100, ownerContributionPercent: 10),
            totalOwnerContributions: [.init(
                commercialAreaCode: "S01", commercialAreaName: "서현",
                point: 1
            )],
            showPrimaryButton: true,
            onTap: { }
        )
        
        IllsangZonePointView(
            topCommercialArea: .init(commercialAreaCode: "S01", commercialAreaName: "서현", point: 100, ownerContributionPercent: 10),
            totalOwnerContributions: [],
            showPrimaryButton: true,
            onTap: { }
        )
        
        IllsangZonePointView(
            topCommercialArea: .init(commercialAreaCode: "S01", commercialAreaName: "서현", point: 100, ownerContributionPercent: 10),
            totalOwnerContributions: [],
            showPrimaryButton: false,
            onTap: { }
        )
    }
    .padding(20)
    .frame(maxHeight: .infinity)
    .background(Color.background)
}
