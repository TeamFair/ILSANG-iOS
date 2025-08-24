//
//  RankingDetailView.swift
//  ILSANG
//
//  Created by Lee Jinhee on 8/24/25.
//

import SwiftUI

struct RankingDetailView: View {
    @StateObject var vm: RankingDetailViewModel
    @Environment(\.dismiss) var dismiss
    
    init(vm: RankingDetailViewModel) {
        _vm = StateObject(wrappedValue: vm)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            NavigationTitleView(title: "랭킹", isSeparatorHidden: true, background: .background) {
                dismiss()
            }
            
            ScrollView {
                imageListView
                    .padding(.bottom, 48)
                Text("유저")
                    .styledFont(.heading1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 20)
                    .padding(.bottom, 16)
                
                LazyVStack(spacing: 12) {
                    ForEach(Array(vm.userRank.enumerated()), id: \.element.customerId) { idx, rank in
                        NavigationLink {
                            OtherUserProfileView(customerId: rank.customerId)
                        } label: {
                            RankingItemView(rank: rank.toRank(idx: idx+1), style: .horizontal(case: .userPoint))
                        }
                    }
                    .padding(.bottom, 72)
                }
            }
            .padding(.top, 8)
        }
        .background(Color.background)
        .navigationBarBackButtonHidden()
        .task {
            await vm.getRankDetail()
            await vm.getImages()
        }
    }
    
    private var imageListView: some View {
        let height: CGFloat = 150
        return VStack(spacing: 0) {
            TabView(selection: $vm.imageIdx) {
                ForEach(Array(vm.imageList.enumerated()), id: \.offset) { idx, image in
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: height)
                        .tag(idx)
                }
            }
            
            .frame(height: height)
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    ForEach(0..<vm.imageList.count, id: \.self) { idx in
                        Circle()
                            .frame(6)
                            .foregroundStyle(vm.imageIdx == idx ? .gray500 : .gray300)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 4)
                .padding(.bottom, 12)
                HStack {
                    Text(vm.regionTitle)
                        .styledFont(.heading3)
                        .foregroundStyle(.black)
                    Image("rank\(vm.regionRank)")
                        .resizable()
                        .frame(22)
                }
                HStack(spacing: 8) {
                    Text("실시간 랭킹: \(vm.regionRank)위")
                        .styledFont(.caption2)
                        .foregroundStyle(.gray500)
                    Rectangle()
                        .frame(width: 1, height: 10)
                        .foregroundStyle(.gray300)
                    Text("누적 점수: \(vm.regionPoint)p")
                        .styledFont(.caption2)
                        .foregroundStyle(.gray500)
                    Spacer(minLength: 0)
                }
            }
            .padding(.horizontal ,16)
            .padding(.bottom ,16)
            .frame(height: 90)
            .frame(maxWidth: .infinity)
            .background(
                Rectangle()
                    .foregroundStyle(.white)
                    .frame(height: 90)
            )
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 20)
    }
}

#Preview {
    RankingDetailView(vm: RankingDetailViewModel())
}
