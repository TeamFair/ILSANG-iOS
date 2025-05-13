//
//  MyPageInfoView.swift
//  ILSANG
//
//  Created by Kim Andrew on 7/18/24.
//

import SwiftUI

struct MyPageInfoView: View {
    let xpPoint: Int?
    let xpStats: [XpStat: Int]
    let honorTitle: String?
    
    @State private var touchedIdx: Int? = nil
    private let contentSpacing: CGFloat = 16
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: contentSpacing) {
                HStack(spacing: contentSpacing) {
                    NavigationLink {
                        MyPageHonorManageView()
                    } label: {
                        MyPageInfoCardView(
                            title: "내 칭호",
                            content: honorTitle ?? "",
                            showTitleChevron: true,
                            trailContent:
                                HonorTrailingView(hasHonorTitie: honorTitle != nil)
                        )
                    }
                    
                    MyPageInfoCardView(
                        title: "총 포인트",
                        content: "\(String(xpPoint ?? 0).formatNumberInText())XP",
                        trailContent: TotalXpTrailingView()
                    )
                }
                
                VStack(alignment: .leading, spacing: 28) {
                    Text("능력별 포인트")
                        .font(.system(size: 12))
                        .foregroundColor(.gray400)
                    
                    ZStack {
                        StatLabels(width: 185)
                            .zIndex(3)
                        
                        PentagonGraphView(
                            xpPoint: xpPoint ?? 10,
                            xpStats: xpStats,
                            width: 185
                        )
                    }
                    
                    shareButtonView
                        .padding(.top, 20)
                }
                .padding(20)
                .background(.white)
                .cornerRadius(12)
            }
        }
        .scrollIndicators(.never)
    }
    
    @MainActor
    private var shareButtonView: some View {
        ShareLink(
            item: shareImage,
            preview: SharePreview("프로필 공유", image: shareImage.image)
        ) {
            Text("공유하기")
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .background(Color.accentColor)
                .cornerRadius(12)
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
        .frame(width: width, height: width, alignment: .center)
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
    
    @MainActor
    private var shareImage: TransferableUIImage {
        return .init(uiimage: profileShareImage, caption: "마이페이지 공유하기")
    }
    
    @MainActor
    private var profileShareImage: UIImage {
        let renderer = ImageRenderer(
            content:
                MyPageShareImage(
                    xpPoint: xpPoint ?? 0,
                    xpStats: xpStats,
                    honorTitle: honorTitle
                )
                .frame(width: 340)
        )
        
        renderer.scale = 3.0
        return renderer.uiImage ?? .init()
    }
}


struct PentagonGraphView: View {
    let xpPoint:Int
    let xpStats: [XpStat: Int]
    let width: CGFloat
    var mainColor: Color = .primaryPurple
    
    var body: some View {
        ZStack {
            BackgroundPolygons(width: width) // 배경 오각형
            if xpPoint != 0 {
                StatPolygon(xpStats: xpStats) // 데이터 오각형
                    .fill(mainColor)
                    .opacity(0.8)
            }
        }
        .frame(width: width, height: width)
        .frame(maxWidth: .infinity)
    }

    private func BackgroundPolygons(width: CGFloat) -> some View {
        ZStack {
            Polygon(count: 5, relativeCornerRadius: 0.20)
                .stroke(.gray300, lineWidth: 1)
                .frame(width: width, height: width)
            
            Polygon(count: 5, relativeCornerRadius: 0.20)
                .stroke(.gray100, lineWidth: 1)
                .frame(width: width * 0.9, height: width * 0.9)
            
            Polygon(count: 5, relativeCornerRadius: 0.20)
                .stroke(.gray100, lineWidth: 1)
                .frame(width: width * 0.5, height: width * 0.5)
        }
    }
}

#Preview {
    MyPageInfoView(
        xpPoint: 0, xpStats: [:], honorTitle: "세상을 움직이는 자"
    )
}
