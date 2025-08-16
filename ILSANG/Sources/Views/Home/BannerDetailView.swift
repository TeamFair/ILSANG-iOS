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
    @Environment(\.dismiss) var dismiss
    
    init(banner: Banner, shouldShowIllsangZoneWarning: Bool, currentSeason: Int, viewModel: BannerDetailViewModel? = nil) {
        if let viewModel = viewModel {
            self._viewModel = State(wrappedValue: viewModel)
        } else {
            self._viewModel = State(wrappedValue: BannerDetailViewModel(
                banner: banner,
                shouldShowIllsangZoneWarning: shouldShowIllsangZoneWarning,
                currentSeason: currentSeason,
                questNetwork: QuestNetwork(),
                favoriteService: FavoriteService(favoriteNetwork: FavoriteNetwork())
            ))
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            NavigationTitleView(title: viewModel.banner.navTitle ?? "배너", isSeparatorHidden: true, background: .background) {
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
                .padding(.top, 8)
            }
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
        .fullScreenCover(isPresented: $viewModel.showSelectIllsangZoneView) {
            IllsangZoneSelectionView { area in
                viewModel.handleIllsangZoneSelection(area)
            }
        }
        // TODO: navigation으로 변경
        .fullScreenCover(isPresented: $viewModel.showQuestEngageView) {
            if let selectedQuest = viewModel.selectedQuest {
                let quizNetwork = QuizNetwork()

                QuestEngageView(
                    vm: QuestEngageViewModel(quest: selectedQuest, quizNetwork: quizNetwork),
                    submitVM: SubmitRouterViewModel(
                        selectedImage: nil,
                        selectedQuest: selectedQuest,
                        submitService: ImageChallengeSubmitService(imageNetwork: ImageNetwork(), challengeNetwork: ChallengeNetwork()),
                        quizNetwork: quizNetwork
                    )
                )
            }
        }
        .sheet(isPresented: $viewModel.showQuestSheet) {
            if let quest = viewModel.selectedQuest {
                let tall = quest.isRepeatQuest || viewModel.selectedQuest?.missionType == .image
                
                QuestDetailView(
                    vm: QuestDetailViewModel(
                        quest: quest,
                        questNetwork: QuestNetwork(),
                        onUpdate: { quest in
                            viewModel.toggleQuestFavorite(quest: quest)
                        })
                ) {
                    viewModel.onQuestApprovalTapped()
                }
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
                SubmitRouterView(selectedQuest: selectedQuest)
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
                
                if viewModel.isCurrentListEmpty {
                    questListEmptyView
                } else {
                    questListView
                }
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
    
    private var questListView: some View {
        LazyVStack(alignment: .leading, spacing: 12) {
            switch viewModel.selectedHeader {
            case .uncomplete:
                ForEach(viewModel.filteredEventQuestList, id: \.id) { quest in
                    QuestItemView(
                        quest: quest,
                        style: BannerEventStyle(),
                        tagTitle: "한정"
                    ) {
                        viewModel.selectQuest(quest)
                    }
                }
                
            case .complete:
                ForEach(viewModel.filteredEventQuestList, id: \.id) { quest in
                    QuestItemView(
                        quest: quest,
                        style: CompletedStyle(),
                        tagTitle: ""
                    ) { }
                }
            }
        }
        .zIndex(-1)
        .frame(minHeight: 600, alignment: .top)
        .padding(.bottom ,72)
    }
    
    private var filterPickerEventView: some View {
        PickerView<BannerEventQuestFilterType>(
            status: $viewModel.eventFilterState.pickerStatus,
            selection: $viewModel.eventFilterState.selectedValue,
            width: 150
        )
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

@Observable
class BannerDetailViewModel {
    var banner: Banner
    private var uncompletedQuest: [QuestViewModelItem] = []
    private var completedQuest: [QuestViewModelItem] = []
    
    var isLoading: Bool = false
    var showQuestSheet: Bool = false
    var showSubmitRouterView: Bool = false {
        didSet {
            // TODO: 해당 데이터가 포함되어있으면 제거 or 리로드하도록 수정
            if showSubmitRouterView == false {
                Task {
                    await fetchQuestByBannerId()
                }
            }
        }
    }
    var showQuestEngageView: Bool = false {
        didSet {
            // TODO: 해당 데이터가 포함되어있으면 제거 or 리로드하도록 수정
            if showSubmitRouterView == false {
                Task {
                    await fetchQuestByBannerId()
                }
            }
        }
    }
    
    var selectedQuest: QuestViewModelItem?
    var selectedHeader: BannerQuestStatus = .uncomplete
    var eventFilterState: FilterPickerState<BannerEventQuestFilterType>
    
    // 일상존 관련
    var currentSeason: Int
    private var shouldShowIllsangZoneWarning: Bool
    var showSelectIllsangZoneView: Bool = false
    
    
    var isNeverShowAlertSelected: Bool = false // 일상존미선택 알럿 - 토글버튼
    var isQuestSheetPending: Bool = false // 퀘스트 시트를 다시 열어야 하는지 여부
    var alertType: AlertType? = nil
    private let dontShowKey = "DontShowIllsangZoneWarning"
    private let seasonKey = "IllsangZoneSeason"
    
    // TODO: 필터 확인
    var filteredEventQuestList: [QuestViewModelItem] {
        let list = (selectedHeader == .uncomplete) ? uncompletedQuest : completedQuest
        return QuestSortHelper.sort(quests: list, by: eventFilterState.selectedValue)
    }
    
    var isCurrentListEmpty: Bool {
        switch selectedHeader {
        case .uncomplete:
            return uncompletedQuest.isEmpty || filteredEventQuestList.isEmpty
        case .complete:
            return completedQuest.isEmpty || filteredEventQuestList.isEmpty
        }
    }
    
    private let questNetwork: QuestNetwork
    private let favoriteService: FavoriteService
    
    init(banner: Banner, shouldShowIllsangZoneWarning: Bool, currentSeason: Int, questNetwork: QuestNetwork, favoriteService: FavoriteService) {
        self.banner = banner
        self.questNetwork = questNetwork
        self.favoriteService = favoriteService
        
        eventFilterState = FilterPickerState(initialValue: BannerEventQuestFilterType.popular)
        
        self.currentSeason = currentSeason
        self.shouldShowIllsangZoneWarning = shouldShowIllsangZoneWarning
        Task { await fetchQuestByBannerId() }
    }
    
    func fetchQuestByBannerId() async {
        isLoading = true
        
        do {
            uncompletedQuest = QuestViewModelItem.mockQuestList
            // completedQuest = [QuestViewModelItem.mockData]
            // let quests = try await questNetwork.getQuests(bannerId: banner.id)
        } catch {
            Log("퀘스트 정보 불러오기 실패")
        }
        
        isLoading = false
    }
    
    func selectQuest(_ quest: QuestViewModelItem) {
        selectedQuest = quest
        if shouldShowIllsangZoneWarning {
            isQuestSheetPending = true // 일상존 선택 후 다시 열기 위해 기록
            alertType = .illsangZoneNotSelected
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.showQuestSheet.toggle()
            }
        }
    }
    
    func onQuestApprovalTapped() {
        showQuestSheet = false
        if selectedQuest?.missionType == .image {
            showSubmitRouterView = true
        } else {
            showQuestEngageView = true
        }
    }
    
    
    func closeFilterPicker() {
        self.eventFilterState.pickerStatus = .close
    }
    
    // 일상존 선택 완료 시
    func handleIllsangZoneSelection(_ area: CommercialArea) {
        self.alertType = .illsangZoneSetSuccess
    }
    
    func finalizeIllsangZoneSelection() {
        alertType = nil
        if isQuestSheetPending {
            isQuestSheetPending = false
            showQuestSheet = true
        }
    }
    
    /// "다시 보지 않기" 선택 시 저장
    func saveDontShowPreferenceIfSelected() {
        if isNeverShowAlertSelected {
            UserDefaults.standard.set(true, forKey: dontShowKey)
            UserDefaults.standard.set(currentSeason, forKey: seasonKey)
            shouldShowIllsangZoneWarning = false
        }
    }
    
    /// 즐겨찾기 상태를 UI에 즉시 반영하고,  서버 반영은 디바운싱 처리
    func toggleQuestFavorite(quest: QuestViewModelItem) {
        favoriteService.toggle(quest: quest)
    }
}

struct QuestSortHelper {
    static func sort(
        quests: [QuestViewModelItem],
        by filter: BannerEventQuestFilterType
    ) -> [QuestViewModelItem] {
        switch filter {
        case .pointHighest:
            return quests.sorted { $0.totalRewardXP() > $1.totalRewardXP() }
        case .pointLowest:
            return quests.sorted { $0.totalRewardXP() < $1.totalRewardXP() }
        case .popular:
            return quests // TODO: 인기순 로직 필요 시 구현
        case .upcoming:
            return quests.sorted {
                guard let date1 = $0.expireDate.toDate(),
                      let date2 = $1.expireDate.toDate() else { return false }
                return date1 < date2
            }
        }
    }
}


#Preview {
    BannerDetailView(banner: Banner.init(id: 0, title: "타이틀", description: "설명설명입니다", navTitle: "일상", imageId: "", image: .img0), shouldShowIllsangZoneWarning: true, currentSeason: 1)
}
