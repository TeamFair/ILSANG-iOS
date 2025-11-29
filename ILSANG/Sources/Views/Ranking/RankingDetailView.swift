//
//  RankingDetailView.swift
//  ILSANG
//
//  Created by Lee Jinhee on 8/24/25.
//

import SwiftUI

struct RankingDetailView: View {
    @StateObject var vm: RankingDetailViewModel
    @StateObject var userRouter: UserRouter
    @EnvironmentObject var dependencies: AppDependencies
    @Environment(\.layout) var layout
    @Environment(\.dismiss) var dismiss
    
    init(vm: RankingDetailViewModel) {
        _vm = StateObject(wrappedValue: vm)
        _userRouter = StateObject(wrappedValue: UserRouter())
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
                    .padding(.leading, layout.horizontalPadding)
                    .padding(.bottom, 16)
                
                LazyVStack(spacing: 12) {
                    if let user = vm.areaUserRank.user  {
                        RankingItemView(style: .currentUserRank(user))
                    }
                    ForEach(vm.areaUserRank.ranks, id: \.userId) { rank in
                        Button {
                            userRouter.navigateToUserProfile(userId: rank.userId)
                        } label: {
                            RankingItemView(style: .userRank(rank))
                        }
                    }
                }
                .padding(.bottom, 170)
            }
            .padding(.top, 8)
        }
        .withUserNavigation(userRouter: userRouter)
        .overlay(alignment: .bottom) {
            if let currentSeason = dependencies.seasonManager.currentSeason,
            let targetDate = currentSeason.endDate.toISO8601Date() {
                SeasonTimerView(season: currentSeason.seasonNumber, targetDate: targetDate)
                    .padding(.horizontal, layout.horizontalPadding)
                    .padding(.bottom, layout.horizontalPadding)
            }
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
            Group {
                if vm.imageList.isEmpty {
                    Text("아직 사진이\n등록되지 않았어요")
                        .styledFont(.heading3)
                        .foregroundStyle(.gray200)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                } else {
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
                }
            }
            .frame(height: height)
            .tabViewStyle(.page(indexDisplayMode: .never))
            .background(Color.gray100)
            
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
                    Text(vm.areaName)
                        .styledFont(.heading3)
                        .foregroundStyle(.black)
                    Image("rank\(vm.areaRank)")
                        .resizable()
                        .frame(22)
                }
                HStack(spacing: 8) {
                    Text("실시간 랭킹: \(vm.areaRank)위")
                        .styledFont(.caption2)
                        .foregroundStyle(.gray500)
                    Rectangle()
                        .frame(width: 1, height: 10)
                        .foregroundStyle(.gray300)
                    Text("누적 점수: \(vm.areaPoint)p")
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
        .padding(.horizontal, layout.horizontalPadding)
    }
}

#Preview {
    RankingDetailView(
        vm: RankingDetailViewModel(
            seasonId: 1,
            areaName: "서현",
            areaRank: 1,
            areaPoint: 1000,
            areaImageIds: [""],
            areaCode: "",
            areaType: .commercial,
            rankRepository: RankRepository(network: RankNetwork()),
            areaNameService: AreaNameService(areaRepository: AreaRepository(network: AreaNetwork()))
        )
    )
}
