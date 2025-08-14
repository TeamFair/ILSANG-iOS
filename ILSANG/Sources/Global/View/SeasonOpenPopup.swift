//
//  SeasonOpenPopup.swift
//  ILSANG
//
//  Created by Lee Jinhee on 8/13/25.
//


import SwiftUI

struct SeasonOpenPopup: View {
    let season: Int
    let seasonStartDate: String
    let seasonEndDate: String
    let onDismiss: (Bool) -> ()
    let onConfirm: (Bool) -> ()
    
    @State private var shouldNeverShowAgain: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button {
                    shouldNeverShowAgain.toggle()
                } label: {
                    HStack(spacing: 4) {
                        Image(.checkThin)
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 9, height: 5.5)
                            .frame(16)
                            .foregroundStyle(shouldNeverShowAgain ? .white : .clear)
                            .background(
                                RoundedRectangle(cornerRadius: 3)
                                    .strokeBorder(
                                        shouldNeverShowAgain ? .clear : .gray200,
                                        style: StrokeStyle(lineWidth: 1)
                                    )
                                    .fill(shouldNeverShowAgain ? .primaryPurple : .clear)
                            )
                            .frame(24)
                        Text("다시 보지 않기")
                            .styledFont(.tabRegular)
                            .foregroundStyle(.gray100)
                    }
                }
                Spacer()
                Button {
                    onDismiss(shouldNeverShowAgain)
                } label: {
                    XmarkButton(color: .white)
                }
            }
            .padding(.bottom, 22)
            
            Text("일상 시즌\(season) 오픈!")
                .font(.custom("GmarketSansBold", size: 36))
                .frame(height: 47)
                .foregroundColor(.white)
                .padding(.bottom, 7)
            
            Text("\(formatDateOnly(seasonStartDate)) ~ \(formatDateOnly(seasonEndDate))")
                .styledFont(.subTitle1)
                .foregroundColor(.gray100)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .roundedBackground(cornerRadius: 20, bgColor: .primary500)
                .padding(.bottom, 38)
            
            Image(.treasure)
                .resizable()
                .frame(130)
                .offset(y: -10)
                .background(
                    Circle()
                        .fill(.primary300)
                        .frame(188)
                )
            
            Button {
                onConfirm(shouldNeverShowAgain)
            } label: {
                Text("시즌 랭킹 보러가기")
                    .styledFont(.semibold, size: 16, lineHeight: 18)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .foregroundStyle(.gray500)
                    .roundedBackground(cornerRadius: 12, bgColor: .white)
            }
        }
        .padding(24)
        .frame(height: 394)
        .roundedBackground(cornerRadius: 12, bgColor: .primaryPurple)
        .padding(.horizontal, 20)
    }
    
    func formatDateOnly(_ isoString: String) -> String {
        // "T" 앞까지만 자르기
        let datePart = isoString.split(separator: "T").first ?? ""
        return datePart.replacingOccurrences(of: "-", with: ".")
    }
}
