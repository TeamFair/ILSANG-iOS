//
//  BannerDetailView.swift
//  ILLSANG
//
//  Created by Lee Jinhee on 8/15/25.
//

import SwiftUI

// TODO: 퀘스트 수행시 리프레시, 외부도 리프레시
// TODO: 일상존 선택 시 홈뷰에서 일상존선택상태 변경
struct BannerDetailView: View {
    @State var viewModel: BannerDetailViewModel
    @EnvironmentObject var dependencies: AppDependencies
    @Environment(\.dismiss) var dismiss
    
    init(viewModel: BannerDetailViewModel) {
        _viewModel = State(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            NavigationTitleView(title: viewModel.banner.navigationTitle, isSeparatorHidden: true, background: .background) {
                dismiss()
            }
            
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    bannerView
                    dividerView
                    questListSectionView
                }
                .onChange(of: viewModel.selectedHeader) { _, _ in
                    viewModel.closeFilterPicker()
                }
                .onChange(of: viewModel.eventFilterState.selectedValue) { _, _ in
                    viewModel.closeFilterPicker()
                }
            }
            .padding(.top, 8)
        }
        .background(Color.background)
        .navigationBarBackButtonHidden()
        .overlay(
            Group {
                if let alert = viewModel.alertType {
                    alertView(alert)
                }
            }
        )
        // TODO: navigation으로 변경
        .navigationDestination(isPresented: $viewModel.showSelectIllsangZoneView) {
            IllsangZoneSelectionView(userRepository: dependencies.userRepository, areaRepository: dependencies.areaRepository) { area in
                viewModel.handleIllsangZoneSelection(area)
            }
        }
        .navigationDestination(isPresented: $viewModel.showChallengeImageView) {
            if let id = viewModel.selectedQuest?.missionId {
                ApprovalDetailView(missionId: id)
            }
        }
        // TODO: navigation으로 변경
        .fullScreenCover(isPresented: $viewModel.showQuestEngageView) {
            if let selectedQuest = viewModel.selectedQuest {
                QuestEngageView(
                    vm: QuestEngageViewModel(quest: selectedQuest,
                                             challengeNetwork: dependencies.challengeNetwork),
                    submitVM: SubmitRouterViewModel(
                        selectedImage: nil,
                        selectedQuest: selectedQuest,
                        submitService: dependencies.imageChallengeSubmitService,
                        challengeNetwork: dependencies.challengeNetwork
                    )
                )
            }
        }
        .sheet(isPresented: $viewModel.showQuestSheet) {
            if let quest = viewModel.selectedQuest {
                let tall = quest.questType == .repeat || viewModel.selectedQuest?.missionType == .photo
                
                QuestDetailView(
                    vm: QuestDetailViewModel(
                        quest: quest,
                        questRepository: dependencies.questRepository,
                        onUpdate: { quest in
                            viewModel.toggleQuestFavorite(quest: quest)
                        })
                , showQuestExImageAction: {
                    viewModel.onChallengeExImageTapped()
                }, questApproveAction: {
                    viewModel.onQuestApprovalTapped()
                })
                .presentationCornerRadius(24)
                .presentationDragIndicator(.hidden)
                .presentationDetents([tall ? .height(UISheetPresentationController.Detent.questDetailDetentHeightTall) : .height(UISheetPresentationController.Detent.questDetailDetentHeightShort)])
                .onAppear {
                    UIApplication.shared.updateSheetDetents(to: [tall ? .questDetailDetentTall : .questDetailDetentShort], whenCurrentDetentsAre: [.large()])
                }
            }
        }
        .fullScreenCover(isPresented: $viewModel.showSubmitRouterView) {
            if let selectedQuest = viewModel.selectedQuest {
                SubmitRouterView(selectedQuest: selectedQuest, submitService: dependencies.imageChallengeSubmitService, challengeNetwork: dependencies.challengeNetwork)
                    .interactiveDismissDisabled()
            }
        }
    }
    
    private var bannerView: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let image = viewModel.banner.image {
                let height: CGFloat = .screenWidth / 3 * 2
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: height)
                    .clipped()
                    .padding(.bottom, 26)
            }
            
            Group {
                Text(viewModel.banner.title)
                    .styledFont(.title2)
                    .foregroundColor(.black)
                    .padding(.bottom, 8)
                Text(viewModel.banner.description)
                    .styledFont(.subTitle1)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.gray500)
                    .padding(.bottom, 16)
            }
            .padding(.horizontal, 20)
        }
    }
    
    private var dividerView: some View {
        Rectangle()
            .frame(height: 8)
            .foregroundColor(.gray100)
            .padding(.bottom, 24)
    }
    
    private var questListSectionView: some View {
        LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
            Section {
                Text("특별 퀘스트 모음")
                    .styledFont(.title2)
                    .foregroundColor(.black)
                    .padding(.top, 4)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .overlay(alignment: .topTrailing) {
                        filterPickerEventView
                            .zIndex(10)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 24)
                
//                if viewModel.isCurrentListEmpty {
//                    questListEmptyView
//                } else {
//                    questListView
//                }
            } header: {
                SelectableTabHeader(
                    selectedItem: $viewModel.selectedHeader,
                    items: BannerQuestStatus.allCases,
                    horizontalPadding: 0,
                    height: 44,
                    hasBottomLine: true
                )
                .padding(.horizontal, -20)
                .background(Color.background)
            }
        }
    }
    
//    private var questListView: some View {
//        LazyVStack(alignment: .leading, spacing: 12) {
//            switch viewModel.selectedHeader {
//            case .uncomplete:
//                ForEach(viewModel.filteredEventQuestList, id: \.id) { quest in
//                    UncompletedBannerQuestItemView(quest: quest) {
//                        viewModel.selectQuest(quest)
//                    }
//                }
//                
//            case .complete:
//                ForEach(viewModel.filteredEventQuestList, id: \.id) { quest in
//                    CompletedQuestItemView(quest: quest)
//                }
//            }
//        }
//        .zIndex(-1)
//        .frame(minHeight: 600, alignment: .top)
//        .padding(.bottom ,72)
//    }
    
    private var filterPickerEventView: some View {
        PickerView(state: viewModel.eventFilterState, width: 85)
    }
    
    private var questListEmptyView: some View {
        ErrorView(
            title: viewModel.selectedHeader.emptyTitle,
            subTitle: viewModel.selectedHeader.emptySubTitle,
            showButton: false
        )
        .frame(height: 600)
    }
    
    @ViewBuilder
    private func alertView(_ alertType: AlertType) -> some View {
        if alertType == .illsangZoneNotSelected {
            SettingAlertView(
                alertType: alertType,
                onCancel: {
                    viewModel.alertType = nil
                    viewModel.saveDontShowPreferenceIfSelected()
                    viewModel.showQuestSheet = true
                }, onConfirm: {
                    viewModel.alertType = nil
                    viewModel.saveDontShowPreferenceIfSelected()
                    viewModel.showSelectIllsangZoneView = true
                }) {
                    Button {
                        viewModel.isNeverShowAlertSelected.toggle()
                    } label: {
                        HStack(spacing: 4) {
                            Image(.checkThin)
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 9, height: 5.5)
                                .frame(16)
                                .foregroundStyle(viewModel.isNeverShowAlertSelected ? .white : .clear)
                                .background(
                                    RoundedRectangle(cornerRadius: 3)
                                        .strokeBorder(
                                            viewModel.isNeverShowAlertSelected ? .clear : .gray200,
                                            style: StrokeStyle(lineWidth: 1)
                                        )
                                        .fill(viewModel.isNeverShowAlertSelected ? .primaryPurple : .clear)
                                )
                                .frame(24)
                            Text("다시 보지 않기")
                                .styledFont(.tabRegular)
                                .foregroundStyle(.gray500)
                        }
                    }
                }
        } else if alertType == .illsangZoneSetSuccess {
            SettingAlertView(
                alertType: alertType,
                onConfirm: { viewModel.finalizeIllsangZoneSelection() }
            )
        }
    }
    //    private var networkErrorView: some View {
    //        ErrorView(
    //            systemImageName: "wifi.exclamationmark",
    //            title: "네트워크 연결 상태를 확인해주세요",
    //            subTitle: "네트워크 연결 상태가 좋지 않아\n퀘스트를 불러올 수 없어요 ",
    //            emoticon: "🥲"
    //        ) {
    //            Task { await viewModel.fetchQuestByBannerId() }
    //        }
    //    }
}

enum BannerQuestStatus: String, Equatable, SelectableTabItem {
    case uncomplete
    case complete
    
    var id: String {
        self.rawValue
    }
    
    var headerText: String {
        switch self {
        case .uncomplete: "진행중"
        case .complete: "완료"
        }
    }
    
    var emptyTitle: String {
        switch self {
        case .uncomplete:
            "퀘스트가 아직 준비중이에요"
        case .complete:
            "완료된 퀘스트가 없어요"
        }
    }
    
    var emptySubTitle: String {
        switch self {
        case .uncomplete:
            "상상할 수 없는 퀘스트를 준비 중이니\n다음 업데이트를 기대해 주세요!"
        case .complete:
            "퀘스트를 수행하러 가볼까요?"
        }
    }
}


enum BannerEventQuestFilterType: String, Hashable, CustomStringConvertible, CaseIterable {
    case upcoming = "임박순"
    case pointHighest = "포인트 높은 순"
    case pointLowest = "포인트 낮은 순"
    case popular = "인기순"
    
    var description: String {
        return self.rawValue
    }
}

struct QuestSortHelper {
    static func sort(
        quests: [QuestViewModelItem],
        by filter: BannerEventQuestFilterType
    ) -> [QuestViewModelItem] {
        switch filter {
        case .pointHighest:
            return quests.sorted { $0.totalRewardPoint() > $1.totalRewardPoint() }
        case .pointLowest:
            return quests.sorted { $0.totalRewardPoint() < $1.totalRewardPoint() }
        case .popular:
            return quests // TODO: 인기순 로직 필요 시 구현
        case .upcoming:
            return quests.sorted {
                guard let date1 = $0.expireDate,
                      let date2 = $1.expireDate else { return false }
                return date1 < date2
            }
        }
    }
}


#Preview {
    BannerDetailView(
        viewModel: BannerDetailViewModel(
            banner: .init(id: 0, title: "title", navigationTitle: "일상", imageId: "", description: "", image: .img0),
            shouldShowIllsangZoneWarning: false,
            currentSeason: 1,
            userRepository: UserRepository(network: UserNetwork()),
            questRepository: QuestRepository(network: QuestNetwork()),
            areaRepository: AreaRepository(network: AreaNetwork()),
            favoriteService: FavoriteService(
                favoriteNetwork: FavoriteNetwork()
            )
        )
    )
}
