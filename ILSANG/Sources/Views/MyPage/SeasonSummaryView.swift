//
//  SeasonSummaryView.swift
//  ILSANG
//
//  Created by Lee Jinhee on 8/29/25.
//


import SwiftUI

struct SeasonSummaryView: View {
    let nickname: String?
    let season: Season
    let summary: PointSummaryItem?
       
    var body: some View {
        if let summary {
            VStack(spacing: 8) {
                let seasonPeriod = seasonPeriodText()
                let displayName = (nickname?.isEmpty ?? true) ? "" : "\(nickname!.shortenedNickname(maxLength: 5))님의 "
                
                subview(
                    title: "\(displayName) 퀘스트 최다 달성 지역은?",
                    value: summary.topMetroAreaName ?? "",
                    caption: seasonPeriod,
                    image: .rewardMetro
                )
                subview(
                    title: "\(displayName) 퀘스트 최다 달성 일상존은?",
                    value: summary.topCommercialAreaName ?? "", 
                    caption: seasonPeriod,
                    image: .rewardCommecial
                )
                subview(
                    title: "\(displayName) 가장 높은 기여도 점수는?",
                    value: "\(summary.topContributionPoint)P",
                    caption: seasonPeriod,
                    image: .rewardContribution
                )
            }
        } else {
            VStack(spacing: 8) {
                Image(.fire)
                    .resizable()
                    .scaledToFit()
                    .frame(36)
                Text("기록을 만들어 볼까요?")
                    .styledFont(.heading1)
                    .foregroundColor(.gray500)
                Text("퀘스트를 수행하면, 내 일상존을\n활성화할 수 있어요")
                    .styledFont(.tabRegular)
                    .foregroundColor(.gray400)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 250)
        }
    }
    
    private func subview(title: String, value: String, caption: String?, image: UIImage) -> some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 12) {
                Text(title.forceCharWrapping)
                    .styledFont(.tabRegular)
                    .foregroundColor(.gray500)
                Text(value)
                    .styledFont(.title1)
                    .foregroundColor(.primary500)
                if let caption {
                    Text(caption)
                        .styledFont(.caption2)
                        .foregroundColor(.gray400)
                }
            }
            Spacer(minLength: 0)

            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(66)
        }
        .padding(16)
        .roundedBackground(cornerRadius: 12, bgColor: .white)
    }
    
    private func seasonPeriodText() -> String? {
        guard
            let start = season.startDate.toISO8601Date()?.toDisplayFormat(.short),
            let end = season.endDate.toISO8601Date()?.toDisplayFormat(.short)
        else { return nil }
        
        return "시즌 \(season.seasonNumber) 기준 (\(start) ~ \(end))"
    }
}

#Preview {
    SeasonSummaryView(
        nickname: "일상123456678888",
        season: .mockData,
        summary: .init(
            topMetroAreaCode: "S01",
            topMetroAreaName: "경기남부",
            topCommercialAreaCode: "G01",
            topCommercialAreaName: "서현",
            topContributionPoint: 10
        )
    )
}
