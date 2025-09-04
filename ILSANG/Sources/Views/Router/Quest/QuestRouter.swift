//
//  QuestRouter.swift
//  ILSANG
//
//  Created by Lee Jinhee on 9/3/25.
//


import SwiftUI

@MainActor
class QuestRouter: ObservableObject {
    // States
    @Published var showQuestSheet = false
    @Published var showSubmitRouter = false
    @Published var showQuestEngage = false
    @Published var showChallengeImage = false
    
    // IllsangZone States
    @Published var showIllsangZoneSelection = false
    @Published var alertType: IllsangZoneAlertType?
    @Published var isNeverShowAlertSelected = false
    @Published var isQuestSheetPending: Bool = false
    
    // Data
    @Published var selectedQuest: QuestViewModelItem = .mockData
    
    // Dependencies
    private let illsangZoneManager: IllsangZoneManager
    private let questRepository: QuestRepositoryInterface
    
    // Callbacks
    private var onFavoriteToggle: ((QuestViewModelItem) -> Void)?
    
    init(illsangZoneManager: IllsangZoneManager, questRepository: QuestRepositoryInterface) {
        self.illsangZoneManager = illsangZoneManager
        self.questRepository = questRepository
    }
    
    // Navigation Methods
    func presentQuestDetail(
        quest: QuestViewModelItem,
        onFavoriteToggle: @escaping (QuestViewModelItem) -> Void
    ) {
        self.onFavoriteToggle = onFavoriteToggle
        self.selectedQuest = quest  // 임시 데이터 세팅
        
        // 퀘스트 상세 정보 로드
        Task {
            do {
                let questDetail = try await questRepository.getQuestDetail(questId: quest.id).get().toQuestItem()
                if let imageId = questDetail.imageId {
                    questDetail.image = await ImageCacheService.shared.loadImageAsync(imageId: imageId)
                }
                self.selectedQuest = questDetail
                
                // 일상존 체크 후 시트 표시
                self.checkIllsangZoneAndPresentSheet()
            } catch {
                Log("퀘스트 상세 정보 로드 실패: \(error)")
            }
        }
    }
    
    private func checkIllsangZoneAndPresentSheet() {
        if !illsangZoneManager.isZoneSelected() && illsangZoneManager.shouldShowWarning {
            isQuestSheetPending = true
            alertType = .illsangZoneNotSelected
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.showQuestSheet = true
            }
        }
    }
    
    func handleQuestApproval() {
        showQuestSheet = false
        
        if selectedQuest.missionType == .photo {
            showSubmitRouter = true
        } else {
            showQuestEngage = true
        }
    }
    
    func handleChallengeExImage() {
        showQuestSheet = false
        showChallengeImage = true
    }
    
    func handleFavoriteToggle() {
        onFavoriteToggle?(selectedQuest)
    }
    
    // MARK: - IllsangZone Navigation Methods
    func handleIllsangZoneButtonTap() {
        if illsangZoneManager.canChangeZone() {
            showIllsangZoneSelection = true
        } else {
            alertType = .illsangZoneChangeNotAllowed
        }
    }
    
    func handleIllsangZoneSelection(_ area: CommercialArea) {
        illsangZoneManager.setZone(area)
        showIllsangZoneSelection = false
        alertType = .illsangZoneSetSuccess
    }
    
    // MARK: - Alert Handling
    func handleAlertCancel() {
        switch alertType {
        case .illsangZoneNotSelected:
            if isNeverShowAlertSelected {
                illsangZoneManager.saveDontShowPreference()
            }
            if isQuestSheetPending {
                isQuestSheetPending = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.showQuestSheet = true
                }
            }
        default:
            break
        }
        dismissAlert()
    }
    
    func handleAlertConfirm() {
        switch alertType {
        case .illsangZoneNotSelected:
            if isNeverShowAlertSelected {
                illsangZoneManager.saveDontShowPreference()
            }
            showIllsangZoneSelection = true
        case .illsangZoneSetSuccess:
            if isQuestSheetPending {
                isQuestSheetPending = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.showQuestSheet = true
                }
            }
        default:
            break
        }
        dismissAlert()
    }
    
    func dismissAlert() {
        alertType = nil
        isNeverShowAlertSelected = false
    }
}