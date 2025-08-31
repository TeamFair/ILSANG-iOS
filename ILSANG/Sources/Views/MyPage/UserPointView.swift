//
//  UserPointView.swift
//  ILSANG
//
//  Created by Lee Jinhee on 8/29/25.
//


import SwiftUI

struct UserPointView: View {
    let seasonNumbers: [Int]
    let points: [PointType: Int]
    let completedQuestCount: Int
    @Binding var selectedSeason: Int
    @Binding var filterState: DynamicFilterPickerState<SeasonFilterType>
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("수행한 퀘스트")
                        .styledFont(.tabRegular)
                        .foregroundColor(.gray500)
                    Text("\(completedQuestCount)개")
                        .styledFont(.title1)
                        .foregroundColor(.black)
                }
                Spacer(minLength: 0)
            }
            
            HStack(spacing: 0) {
                subview("일상지역", points[.metro, default: 0], .rewardMetro)
                separator
                subview("일상존", points[.commercial, default: 0], .rewardCommecial)
                separator
                subview("기여도", points[.contribution, default: 0], .rewardContribution)
            }
            .padding(.horizontal, -16)
            
        }
        .overlay(alignment: .topTrailing) {
            PickerView(state: filterState, showBorder: true, width: 150)
        }
        .padding(16)
        .roundedBackground(cornerRadius: 12, bgColor: .white)
    }
    
    private func subview(_ title: String, _ point: Int, _ image: UIImage) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 4) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(18)
                Text(title)
                    .styledFont(.tabRegular)
                    .foregroundColor(.gray400)
                Spacer(minLength: 0)
            }
            Text("획득 포인트")
                .styledFont(.caption2)
                .foregroundColor(.gray400)
            Text("\(point)P")
                .styledFont(.title2)
                .foregroundColor(.gray500)
        }
        .padding(.vertical, 16)
        .padding(.leading, 16)
    }
    
    private var separator: some View {
        Rectangle()
            .fill(.gray100)
            .frame(width: 1, height: 110)
    }
}

#Preview {
    UserPointView(
        seasonNumbers: [-1,1,2],
        points: [.commercial:10, .contribution: 100, .metro: 20],
        completedQuestCount: 2,
        selectedSeason: .constant(1),
        filterState: .constant(.init(initialValue: .init(seasonNumber: 1)))
    )
}
