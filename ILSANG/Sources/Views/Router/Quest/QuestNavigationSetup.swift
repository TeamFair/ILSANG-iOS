//
//  QuestNavigationSetup.swift
//  ILSANG
//
//  Created by Lee Jinhee on 9/3/25.
//


import SwiftUI

extension View {
    func withQuestNavigation(questRouter: QuestRouter) -> some View {
        self.modifier(QuestNavigationSetup(questRouter: questRouter))
    }
}

struct QuestNavigationSetup: ViewModifier {
    @ObservedObject var questRouter: QuestRouter
    @State private var missionTitleHeight: CGFloat = 0
    @EnvironmentObject var dependencies: AppDependencies
    
    func body(content: Content) -> some View {
        content
        // 퀘스트 상세 시트
            .sheet(isPresented: $questRouter.showQuestSheet) {
                let detent = PresentationDetent.baseHeightForQuest(questRouter.selectedQuest) + missionTitleHeight
                return QuestDetailView(
                    quest: questRouter.selectedQuest,
                    questRepository: dependencies.questRepository,
                    onFavorite: { _ in questRouter.handleFavoriteToggle() },
                    showQuestExImageAction: { questRouter.handleChallengeExImage() },
                    questApproveAction: { questRouter.handleQuestApproval() },
                    onHeightChange: { height in
                        missionTitleHeight = height
                    }
                )
                .presentationCornerRadius(24)
                .presentationDragIndicator(.hidden)
                .presentationDetents([.height(detent)])
                .onDisappear {
                    missionTitleHeight = 0
                }
            }
        
        // 도전내역 제출 라우터
            .fullScreenCover(isPresented: $questRouter.showSubmitRouter) {
                SubmitRouterView(
                    selectedQuest: questRouter.selectedQuest,
                    submitService: dependencies.imageChallengeSubmitService,
                    challengeNetwork: dependencies.challengeNetwork
                )
                .interactiveDismissDisabled()
            }
        // 퀘스트 참여
            .navigationDestination(isPresented: $questRouter.showQuestEngage) {
                QuestEngageView(
                    quest: questRouter.selectedQuest,
                    selectedImage: nil,
                    selectedQuest: questRouter.selectedQuest,
                    challengeNetwork: dependencies.challengeNetwork,
                    submitService: dependencies.imageChallengeSubmitService
                )
            }
        // 도전내역 상세
            .navigationDestination(isPresented: $questRouter.showChallengeImage) {
                MissionApprovalView(missionId: questRouter.selectedQuest.missionId, quest: questRouter.selectedQuest)
            }
        // 일상존 선택
            .navigationDestination(isPresented: $questRouter.showIllsangZoneSelection) {
                IllsangZoneSelectionView(
                    userRepository: dependencies.userRepository,
                    areaRepository: dependencies.areaRepository
                ) { [weak questRouter] area in
                    questRouter?.handleIllsangZoneSelection(area)
                }
                .environmentObject(dependencies)
            }
        
        // 일상존 알럿
            .overlay(
                Group {
                    if let alertType = questRouter.alertType {
                        IllsangZoneAlertView(
                            alertType: alertType,
                            isNeverShowSelected: $questRouter.isNeverShowAlertSelected,
                            onCancel: { [weak questRouter] in
                                questRouter?.handleAlertCancel()
                            },
                            onConfirm: { [weak questRouter] in
                                questRouter?.handleAlertConfirm()
                            }
                        )
                    }
                }
            )
    }
}
