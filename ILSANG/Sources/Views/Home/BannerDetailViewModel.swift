//
//  BannerDetailViewModel.swift
//  ILSANG
//
//  Created by Lee Jinhee on 8/16/25.
//


import UIKit

@Observable
class BannerDetailViewModel {
    var banner: BannerViewModelItem
    private var uncompletedQuest: [QuestViewModelItem] = []
    private var completedQuest: [QuestViewModelItem] = []
    
    var isLoading: Bool = false
    var showQuestSheet: Bool = false
    var showChallengeImageView: Bool = false
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
    var eventFilterState: StaticFilterPickerState<BannerEventQuestFilterType>
    
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

    let userRepository: UserRepositoryInterface
    private let questRepository: QuestRepositoryInterface
    let areaRepository: AreaRepositoryInterface
    private let favoriteService: FavoriteService
    
    init(
        banner: BannerViewModelItem,
        shouldShowIllsangZoneWarning: Bool,
        currentSeason: Int,
        userRepository: UserRepositoryInterface,
        questRepository: QuestRepositoryInterface,
        areaRepository: AreaRepositoryInterface,
        favoriteService: FavoriteService
    ) {
        self.banner = banner
        self.userRepository = userRepository
        self.questRepository = questRepository
        self.areaRepository = areaRepository
        self.favoriteService = favoriteService
        
        eventFilterState = StaticFilterPickerState(initialValue: .popular)
        
        self.currentSeason = currentSeason
        self.shouldShowIllsangZoneWarning = shouldShowIllsangZoneWarning
        Task { await fetchQuestByBannerId() }
    }
    
    func fetchQuestByBannerId() async {
        isLoading = true
        
        do {
            uncompletedQuest = [QuestViewModelItem.mockData]
            completedQuest = [QuestViewModelItem.mockData]
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
        if selectedQuest?.missionType == .photo {
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
    
    func onChallengeExImageTapped() {
        showQuestSheet = false
        showChallengeImageView = true
    }
}
