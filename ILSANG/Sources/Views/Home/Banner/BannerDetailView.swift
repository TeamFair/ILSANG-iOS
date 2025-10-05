//
//  BannerDetailView.swift
//  ILLSANG
//
//  Created by Lee Jinhee on 8/15/25.
//

import SwiftUI

// TODO: 일상존 선택 시 홈뷰에서 일상존 선택 상태 변경
struct BannerDetailView: View {
    @StateObject var viewModel: BannerDetailViewModel
    @StateObject var questRouter: QuestRouter
    @StateObject var userRouter: UserRouter
    @EnvironmentObject var dependencies: AppDependencies
    @Environment(\.dismiss) var dismiss
    
    init(
        banner: BannerItem,
        userRepository: UserRepositoryInterface,
        questRepository: QuestRepositoryInterface,
        areaRepository: AreaRepositoryInterface,
        favoriteService: FavoriteService,
        illsangZoneManager: IllsangZoneManager,
        questSubmissionNotifier: QuestSubmissionNotifier
    ) {
        _viewModel = StateObject(
            wrappedValue: BannerDetailViewModel(
                banner: banner,
                userRepository: userRepository,
                questRepository: questRepository,
                areaRepository: areaRepository,
                favoriteService: favoriteService,
                questSubmissionNotifier: questSubmissionNotifier
            )
        )
        self._questRouter = StateObject(
            wrappedValue: QuestRouter(
                illsangZoneManager: illsangZoneManager, questRepository: questRepository
            )
        )
        self._userRouter = StateObject(wrappedValue: UserRouter())
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
            }
            .padding(.top, 8)
        }
        .background(Color.background)
        .navigationBarBackButtonHidden()
        .withQuestNavigation(questRouter: questRouter)
        .withUserNavigation(userRouter: userRouter)
        .task { await viewModel.loadDataIfNeeded() }
        .onChange(of: viewModel.selectedHeader) { _, _ in
            viewModel.closeFilterPicker()
        }
        .onChange(of: viewModel.eventFilterState.selectedValue) { _, _ in
            viewModel.closeFilterPicker()
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
                
                switch viewModel.viewStatus {
                case .error:
                    networkErrorView
                case .loading:
                    ProgressView()
                        .frame(maxHeight: .infinity, alignment: .center)
                case .loaded:
                    if viewModel.isFilteredListEmpty {
                        questListEmptyView
                    } else {
                        questListView
                    }
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
                ForEach(viewModel.filteredQuestList, id: \.id) { quest in
                    UncompletedBannerQuestItemView(quest: quest) { [weak viewModel, weak questRouter] in
                        guard let viewModel = viewModel, let questRouter = questRouter else { return }
                        AnalyticsService.logEvent(.questItemClick(questId: quest.id, questType: quest.questType?.rawValue.uppercased() ?? ""))
                        viewModel.closeFilterPicker()
                        questRouter.presentQuestDetail(quest: quest) { [weak viewModel] quest in
                            viewModel?.toggleFavoriteStatus(quest: quest)
                        }
                        
                    }
                }
                if viewModel.uncompletedPaginationManager.canLoadMoreData() {
                    ProgressView()
                        .onAppear {
                            Task { [viewModel] in
                                await viewModel.uncompletedPaginationManager.loadData(isRefreshing: false)
                            }
                        }
                }
            case .complete:
                ForEach(viewModel.filteredQuestList, id: \.id) { quest in
                    CompletedQuestItemView(quest: quest)
                }
                if viewModel.completedPaginationManager.canLoadMoreData() {
                    ProgressView()
                        .onAppear {
                            Task { [viewModel] in
                                await viewModel.completedPaginationManager.loadData(isRefreshing: false)
                            }
                        }
                }
            }
        }
        .zIndex(-1)
        .padding(.bottom, 72)
    }
    
    private var filterPickerEventView: some View {
        PickerView(state: viewModel.eventFilterState, width: 150)
    }
    
    private var questListEmptyView: some View {
        ErrorView(
            title: viewModel.selectedHeader.emptyTitle,
            subTitle: viewModel.selectedHeader.emptySubTitle,
            showButton: false
        )
        .frame(height: 320, alignment: .center)
        .zIndex(-1)
        .padding(.bottom, 120)
    }
    
    private var networkErrorView: some View {
        ErrorView(
            systemImageName: "wifi.exclamationmark",
            title: "네트워크 연결 상태를 확인해주세요",
            subTitle: "네트워크 연결 상태가 좋지 않아\n퀘스트를 불러올 수 없어요 ",
            emoticon: "🥲"
        ) {
            Task { await viewModel.loadInitialData() }
        }
        .frame(height: 320, alignment: .center)
        .zIndex(-1)
        .padding(.bottom, 120)
    }
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
            "퀘스트를 모두 완료하셨어요!"
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

#Preview {
    BannerDetailView(
        banner: .init(id: 0, title: "title", navigationTitle: "일상", imageId: "", description: "", image: .img0),
        userRepository: UserRepository(network: UserNetwork()),
        questRepository: QuestRepository(network: QuestNetwork()),
        areaRepository: AreaRepository(network: AreaNetwork()),
        favoriteService: FavoriteService(favoriteNetwork: FavoriteNetwork()),
        illsangZoneManager: IllsangZoneManager(
            areaNameService: AreaNameService(areaRepository: AreaRepository(network: AreaNetwork()))
        ),
        questSubmissionNotifier: QuestSubmissionNotifier()
    )
}
