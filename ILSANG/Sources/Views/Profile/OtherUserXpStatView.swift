//
//  OtherUserXpStatView.swift
//  ILSANG
//
//  Created by Lee Jinhee on 3/8/25.
//

import SwiftUI

struct OtherUserXpStatView: View {
    let xpPoint: Int?
    let xpStats: [XpStat: Int]
    
    @State private var touchedIdx: Int? = nil
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12).fill(.white)
            
            StatLabels(width: 185)
                .zIndex(13)
                .padding(.top, 44)
            
            PentagonGraphView(
                xpPoint: xpPoint ?? 10,
                xpStats: xpStats,
                width: 185
            )
            .padding(28)
            .padding(.top, 16)
        }
    }
    
    // 스탯 레이블 위치 지정
    private func StatLabels(width: CGFloat) -> some View {
        ForEach(Array(XpStat.allCases.enumerated()), id: \.element) { index, stat in
            let angle = calculateAngle(index: index, totalCount: XpStat.sortedStat.count)
            let labelPoint = calculateLabelPosition(width: width, angle: angle)
            
            ZStack {
                PentagonStatLabel(xpStat: stat)
                    .position(x: labelPoint.x, y: labelPoint.y)
                    .onTapGesture {
                        touchedIdx = (touchedIdx == index) ? nil : index
                    }
                
                if touchedIdx == index, let point = xpStats[stat] {
                    PopoverStatLabel(stat: stat, statPoint: point)
                        .position(x: labelPoint.x, y: labelPoint.y - 25) // 위치 조정
                        .zIndex(3)
                }
            }
            .padding(.top, 20)
        }
        .frame(width: width, alignment: .center)
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
    
    private func PentagonStatLabel(xpStat: XpStat) -> some View {
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
    
    private func PopoverStatLabel(stat: XpStat, statPoint: Int) -> some View {
        VStack(spacing: 0) {
            Text("\(stat.headerText): \(statPoint) P")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.white)
                .padding(8)
                .background(.accent)
                .cornerRadius(8)
            
            Polygon(count: 3, cornerRadius: 2)
                .frame(width: 18, height: 18)
                .foregroundColor(.accent)
                .offset(y: 8)
                .rotationEffect(.degrees(180))
        }
    }
}

#Preview {
    OtherUserXpStatView(xpPoint: 140, xpStats: [.charm: 10, .fun: 40, .sociability: 50, .intellect: 40])
}
