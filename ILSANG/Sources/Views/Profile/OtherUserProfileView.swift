//
//  OtherUserProfileView.swift
//  ILSANG
//
//  Created by Lee Jinhee on 3/8/25.
//

import SwiftUI

struct OtherUserProfileView: View {
    @StateObject var vm: OtherUserProfileViewModel
    @EnvironmentObject var dependencies: AppDependencies
    @Environment(\.layout) var layout
    @Environment(\.dismiss) var dismiss
    
    init(
        userId: String,
        userRepository: UserRepositoryInterface,
        missionHistoryRepository: MissionHistoryRepository,
        areaNameService: AreaNameProvider,
        seasonManager: SeasonManager
    ) {
        _vm = StateObject(
            wrappedValue: OtherUserProfileViewModel(
                userId: userId,
                userRepository: userRepository,
                missionHistoryRepository: missionHistoryRepository,
                areaNameService: areaNameService,
                seasonManager: seasonManager
            )
        )
    }
    
    var body: some View {
        VStack(spacing: 0) {
            header  // 타이틀
            content // 프로필 & 일상존 & 포인트 & 도전내역 목록
        }
        .background(Color.background)
        .navigationBarBackButtonHidden(true)
        .task {
            await vm.loadDataIfNeeded()
        }
        .onChange(of: vm.selectedMissionType) { _, _ in
            // TODO: scroll to top
            Task { await vm.loadMissionDataIfNeeded() }
        }
    }
    
    private var header: some View {
        NavigationTitleView(title: "프로필 정보", isSeparatorHidden: false) {
            dismiss()
        }
        .padding(.bottom, 8) // 세로로 긴 이미지 대응 (NavigationTitleView의 bottom 패딩과 겹침)
    }
    
    private var content: some View {
        ScrollView {
            VStack(spacing: 48) {
                userProfileSection
                illsangZoneSection
                pointSection
                challengeSection
            }
            .padding(.top, 16)
        }
    }
    
    private var userProfileSection: some View {
        HStack(spacing: 16) {
            // 프로필 이미지
            ProfileImageView(profileImage: vm.userProfileImage, imageSize: 57)
                .overlay {
                    TagView(title: "LV.\(vm.currentLv)", tagStyle: .levelStroke)
                        .offset(y: 24)
                }
            
            // 프로필 상세 - 닉네임, 레벨
            VStack(alignment: .leading, spacing: 8) {
                Text(vm.userData?.nickname ?? "일상")
                    .styledFont(.heading2)
                    .foregroundStyle(.gray500)
                    .multilineTextAlignment(.leading)
                
                if let honor = vm.userData?.title {
                    HonorIconView(
                        honorTitle: honor.name,
                        grade: honor.grade,
                        imageSize: 20,
                        spacing: 4,
                        font: .badge1,
                        fgColor: .gray500
                    )
                }
                
                HStack(alignment: .center, spacing: 6) {
                    ProgressBar(progress: vm.progress)
                    
                    Text("\(vm.points.reduce(0) { $0 + $1.value })P")
                        .styledFont(.bold, size: 13, lineHeight: 13, tracking: 0)
                        .foregroundStyle(.primaryPurple)
                }
            }
        }
        .padding(16)
        .roundedBackground(cornerRadius: 12)
        .padding(.horizontal, layout.horizontalPadding)
    }
    
    @ViewBuilder
    private var illsangZoneSection: some View {
        if let pointCommercial = vm.pointCommercial,
           let topCommercialArea = pointCommercial.topCommercialArea,
           let nickname = vm.userData?.nickname {
            TitleWithContentView(
                title: "\(nickname)님의 일상존",
                style: .my,
                content:
                    Group {
                        let percents = pointCommercial.totalOwnerContributions.pointRatios()
                        let contributionsWithPercents = Array(zip(pointCommercial.totalOwnerContributions, percents))
                        IllsangZonePointView(
                            topCommercialArea: topCommercialArea,
                            contributions: contributionsWithPercents,
                            showPrimaryButton: false
                        )
                        .padding(.horizontal, layout.horizontalPadding)
                    }
            )
        }
    }
    
    private var pointSection: some View {
        let nickname = vm.userData?.nickname ?? ""
        let titleText = nickname.isEmpty ? "포인트" : "\(nickname)님의 포인트"
        
        return TitleWithContentView(
            title: titleText,
            style: .my,
            content:
                UserPointView(
                    seasonNumbers: dependencies.seasonManager.seasons.map { $0.seasonNumber },
                    points: vm.points,
                    completedQuestCount: vm.completedQuestCount,
                    selectedSeason: $vm.selectedSeasonNumber,
                    filterState: $vm.seasonFilterState
                )
                .padding(.horizontal, layout.horizontalPadding)
        )
    }
    
    private var challengeSection: some View {
        let nickname = vm.userData?.nickname ?? ""
        let titleText = nickname.isEmpty ? "포인트" : "\(nickname)님이 수행한 퀘스트"
        
        return TitleWithContentView(
            title: titleText,
            style: .my,
            content:
                VStack(alignment: .leading, spacing: 20) {
                    SelectableTabHeader(
                        selectedItem: $vm.selectedMissionType,
                        items: MissionType.allCases,
                        horizontalPadding: 0,
                        height: 44,
                        hasBottomLine: true
                    )
                    
                    OtherUserChallengeList(vm: vm)
                }
                .padding(.horizontal, layout.horizontalPadding)
        )
    }
}

#Preview {
    OtherUserProfileView(
        userId: "",
        userRepository: UserRepository(network: UserNetwork()),
        missionHistoryRepository: MissionHistoryRepository(network: MissionHistoryNetwork()),
        areaNameService: AreaNameService(areaRepository: AreaRepository(network: AreaNetwork())),
        seasonManager: SeasonManager(seasonNetwork: SeasonNetwork())
    )
}

