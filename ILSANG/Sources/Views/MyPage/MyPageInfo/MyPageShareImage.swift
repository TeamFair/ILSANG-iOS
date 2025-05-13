//
//  MypageShareImage.swift
//  ILSANG
//
//  Created by Kim Andrew on 11/25/24.
//

import SwiftUI

struct MyPageShareImage: View {
    let xpPoint: Int
    let xpStats: [XpStat: Int]
    let honorTitle: String?
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 16) {
                MyPageInfoCardView(
                    title: "내 칭호",
                    content: honorTitle ?? "",
                    showTitleChevron: true,
                    trailContent:
                        HonorTrailingView(hasHonorTitie: honorTitle != nil)
                )
                
                MyPageInfoCardView(
                    title: "총 포인트",
                    content: "\(String(xpPoint).formatNumberInText())XP",
                    trailContent: TotalXpTrailingView()
                )
            }
            
            VStack(alignment: .leading, spacing: 24) {
                Text("능력별 포인트")
                    .font(.system(size: 12))
                    .foregroundColor(.gray400)
                ZStack {
                    statLabels(width: 185) // 능력치 레이블

                    PentagonGraphView(xpPoint: xpPoint, xpStats: xpStats, width: 185)
                }
                .frame(width: 185, height: 185)
                .frame(maxWidth: .infinity)

                Spacer()
            }
            .padding(20)
            .background(.white)
            .cornerRadius(12)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .foregroundColor(.gray300)
    }

    // 능력치 레이블 위치 지정
    private func statLabels(width: CGFloat) -> some View {
        ForEach(Array(XpStat.allCases.enumerated()), id: \.element) { index, stat in
            let angle = calculateAngle(index: index, totalCount: XpStat.sortedStat.count)
            let labelPoint = calculateLabelPosition(width: width, angle: angle)

            pentagonStatLabel(xpStat: stat)
                .position(x: labelPoint.x, y: labelPoint.y)
              
            .padding(.top, 20)
        }
        .frame(width: width, height: width, alignment: .center)
    }

    // 능력치 레이블 뷰
    private func pentagonStatLabel(xpStat: XpStat) -> some View {
        HStack(spacing: 0) {
            Image(xpStat.image)
                .resizable()
                .scaledToFit()
                .frame(height: 20)
                .frame(width: 30, height: 30)
            Text(xpStat.headerText)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.gray500)
        }
    }
    
    private func calculateAngle(index: Int, totalCount: Int) -> CGFloat {
        return (CGFloat(index) / CGFloat(totalCount)) * 2 * .pi - .pi / 2
    }

    private func calculateLabelPosition(width: CGFloat, angle: CGFloat) -> CGPoint {
        let radius = width / 2
        return CGPoint(
            x: width / 2 + (radius + 36) * cos(angle),
            y: width / 2 + (radius + 14) * sin(angle) - 16
        )
    }
}
