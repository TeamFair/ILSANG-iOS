//
//  MyPageView.swift
//  ILSANG
//
//  Created by Lee Jinhee on 5/20/24.
//

import SwiftUI

struct MyPageView: View {
    @StateObject var vm: MyPageViewModel
    @EnvironmentObject var dependencies: AppDependencies
    @EnvironmentObject var sharedState: SharedState
    
    init(
        vm: MyPageViewModel
    ) {
        _vm = StateObject(wrappedValue: vm)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            header  // 타이틀 & 설정 버튼
            content // 프로필일상존 / 포인트 / 시즌요약
        }
        .background(Color.background)
        .task {
            await vm.loadData()
        }
    }
    
    private var header: some View {
        HStack {
            Text("내 프로필")
                .font(.system(size: 21))
                .fontWeight(.bold)
                .foregroundColor(.gray500)
            Spacer()
            NavigationLink(destination: SettingView()) {
                Image("Setting")
                    .foregroundColor(.gray500)
            }
        }
        .frame(height: 50)
        .padding(.bottom, 5)
        .padding(.horizontal, 20)
    }
    
    @ViewBuilder
    private var content: some View {
        ScrollView {
            VStack(spacing: 0) {
                // 프로필
                VStack(spacing: 20) {
                    MyPageProfile(
                        nickName: vm.currentUser?.nickname,
                        profileImage: vm.currentUser?.profileImage,
                        profileImageId: vm.currentUser?.profileImageId,
                        level: vm.xpStatus.currentLv,
                        progress: vm.xpStatus.progress,
                        honorTitle: vm.currentUser?.title?.name,
                        honorType: vm.currentUser?.title?.grade
                    )
                    
                    HStack {
                        NavigationLink {
                            UserMissionHistoryView(
                                vm: UserMissionHistoryViewModel(
                                    missionHistoryRepository: dependencies.missionHistoryRepository
                                )
                            )
                        } label: {
                            navigationButtonLabel(title: "수행한 퀘스트", image: .myQuest)
                        }
                        NavigationLink {
                            FavoriteListView(
                                viewModel: FavoriteListViewModel(
                                    questRepository: dependencies.questRepository,
                                    favoriteService: dependencies.favoriteService,
                                    selectedCommercialArea: sharedState.selectedCommercialArea
                                ),
                                questRepository: dependencies.questRepository,
                                illsangZoneManager: dependencies.illsangZoneManager
                            )
                        } label: {
                            navigationButtonLabel(title: "즐겨찾기 퀘스트", image: .myStar)
                        }
                        NavigationLink {
                            CouponListView(
                                viewModel: CouponListViewModel(
                                    couponRepository: dependencies.couponRepository
                                )
                            )
                        } label: {
                            navigationButtonLabel(title: "쿠폰", image: .coupon)
                        }
                    }
                }
                .padding(.top, 16)
                .roundedBackground(cornerRadius: 16, bgColor: .white)
                .padding(.horizontal, 20)
                .padding(.bottom, 48)
                
                // 내 일상존
                if let pointCommercial = vm.pointCommercial, pointCommercial.topCommercialArea != nil || !pointCommercial.totalOwnerContributions.isEmpty {
                    TitleWithContentView(
                        title: "내 일상존",
                        style: .my,
                        content:
                            Group {
                                let percents = pointCommercial.totalOwnerContributions.pointRatios()
                                let contributionsWithPercents = Array(zip(pointCommercial.totalOwnerContributions, percents))
                                IllsangZonePointView(
                                    topCommercialArea: pointCommercial.topCommercialArea,
                                    contributions: contributionsWithPercents,
                                    showPrimaryButton: true
                                ) {
                                    sharedState.selectedTab = .quest
                                }
                                .padding(.horizontal, 20)
                            }
                    )
                    .padding(.bottom, 48)
                }
                
                // 내 포인트
                TitleWithContentView(
                    title: "내 포인트",
                    style: .my,
                    content:
                        UserPointView(
                            seasonNumbers: dependencies.seasonManager.seasons.map { $0.seasonNumber },
                            points: vm.points,
                            completedQuestCount: vm.completedQuestCount,
                            selectedSeason: $vm.selectedSeasonNumber,
                            filterState: $vm.seasonFilterState
                        )
                        .padding(.horizontal, 20)
                )
                .padding(.bottom, 48)
                
                // 시즌 요약: 현재 시즌이 없으면 미표시
                if let currentSeason = vm.currentSeason {
                    TitleWithContentView(
                        title: "시즌 요약",
                        style: .my,
                        content:
                            SeasonSummaryView(
                                nickname: vm.currentUser?.nickname, season: currentSeason, summary: vm.pointSummary
                            )
                            .padding(.horizontal, 20)
                    )
                }
            }
            .padding(.bottom, 72)
        }
        .refreshable {
            await vm.refreshData()
        }
    }
    
    private func navigationButtonLabel(title: String, image: UIImage) -> some View {
        VStack(spacing: 4) {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(36)
            Text(title)
                .styledFont(.tabRegular)
                .foregroundStyle(.gray500)
        }
        .padding(.top, 14)
        .padding(.bottom, 24)
        .frame(maxWidth: .infinity)
    }
}

struct EmptyStateView: View {
    var message: String
    var fontScale: FontScale
    
    enum FontScale {
        case big
        case small
        
        var font: FontStyle {
            switch self {
            case .big:
                return .init(size: 23, weight: .semibold, lineHeight: 33, tracking: 0)
            case .small:
                return .init(size: 17, weight: .medium, lineHeight: 20, tracking: 0)
            }
        }
    }
    
    var body: some View {
        Text(message)
            .styledFont(fontScale.font)
            .foregroundColor(.gray300)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    MyPageView(
        vm: MyPageViewModel(
            userRepository: UserRepository(network: UserNetwork()),
            imageNetwork: ImageNetwork(),
            areaNameService: AreaNameService(areaRepository: AreaRepository(network: AreaNetwork())),
            seasonManager: SeasonManager(seasonNetwork: SeasonNetwork())
        )
    )
}
