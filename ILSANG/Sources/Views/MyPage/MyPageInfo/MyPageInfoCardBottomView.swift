//
//  MyPageInfoCardBottomView.swift
//  ILSANG
//
//  Created by Lee Jinhee on 4/26/25.
//


import SwiftUI

struct HonorTrailingView: View {
    let hasHonorTitie: Bool
    
    var body: some View {
        if hasHonorTitie {
            HStack(spacing: 4) {
                Group {
                    Image(.honorBlue)
                        .resizable()
                    Image(.honorRed)
                        .resizable()
                    Image(.honorGold)
                        .resizable()
                }
                .scaledToFit()
                .frame(36)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        } else {
            VStack(alignment: .center, spacing: 4) {
                Text("칭호가 없어요")
                    .styledFont(.title2)
                    .foregroundStyle(.gray300)
                Text("퀘스트 수행으로\n칭호를 획득해 보세요")
                    .styledFont(.caption2)
                    .foregroundStyle(.gray200)
                    .multilineTextAlignment(.center)
                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }
}

struct TotalXpTrailingView: View {
    var body: some View {
        Image(.xpGraph)
            .resizable()
            .frame(54)
            .frame(maxWidth: .infinity, alignment: .trailing)
    }
}
