//
//  HonorListItemView.swift
//  ILSANG
//
//  Created by Lee Jinhee on 5/13/25.
//

import SwiftUI

struct HonorListItemView: View {
    let honor: TitleItem
    let rowColumnWidth: CGFloat
    let onSelect: () -> Void
    let onShowRankingView: () -> ()
    
    var body: some View {
        HStack(spacing: 0) {
            Button(action: onSelect) {
                RoundedRectangle(cornerRadius: 4)
                    .inset(by: 0.5)
                    .stroke(lineWidth: honor.isSelected ? 0 : 1)
                    .frame(20)
                    .foregroundStyle(honor.isSelected ? .clear : .gray200)
                    .background(honor.isSelected ? .primaryPurple : .clear)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .overlay {
                        if honor.isSelected {
                            Image(.checkThin)
                                .renderingMode(.template)
                                .foregroundStyle(.white)
                        }
                    }
                    .frame(width: rowColumnWidth)
            }
            
            Button(action: onShowRankingView) {
                Text(honor.name.forceCharWrapping)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(.gray400)
                    .padding(.horizontal, 8)
            }
            .disabled(honor.grade != .legend) // 전설 칭호만 랭킹 조회 가능
            
            Text(honor.condition.forceCharWrapping)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
                .foregroundStyle(.gray400)
                .padding(.horizontal, 8)
            
            Circle()
                .inset(by: 0.5)
                .stroke(lineWidth: 1)
                .frame(width: 20, height: 20)
                .foregroundStyle(honor.isAcquired ? .primaryPurple : .gray200)
                .overlay {
                    if honor.isAcquired {
                        Image(.checkThin)
                            .renderingMode(.template)
                            .foregroundStyle(.primaryPurple)
                    }
                }
                .frame(width: rowColumnWidth)
        }
        .padding(.vertical, 16)
        .styledFont(.tabRegular)
        .overlay(alignment: .top) {
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.gray100)
        }
    }
}


#Preview {
    HonorListItemView(
        honor: .init(
            titleId: "1",
            name: "일상 회원가입 시",
            condition: "조건",
            grade: .legend,
            historyId: 1,
            isSelected: false
        ),
        rowColumnWidth: 50
    ) { } onShowRankingView: { }
}
