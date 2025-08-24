//
//  SubmitViewModel.swift
//  ILSANG
//
//  Created by Lee Jinhee on 6/27/24.
//

import SwiftUI

@MainActor
class SubmitRouterViewModel: ObservableObject {
    @Published var selectedImage: UIImage?
    @Published var showSubmitAlertView: Bool = false
    @Published var submitStatus: SubmitStatus = .inProgress
    
    private let submitService: ImageChallengeSubmitService
    private let challengeNetwork: ChallengeNetwork

    let selectedQuest: QuestViewModelItem
    private var submitTask: Task<Void, Never>?
    
    init(selectedImage: UIImage? = nil, selectedQuest: QuestViewModelItem, submitService: ImageChallengeSubmitService, challengeNetwork: ChallengeNetwork) {
        self.selectedImage = selectedImage
        self.selectedQuest = selectedQuest
        self.submitService = submitService
        self.challengeNetwork = challengeNetwork
    }
    
    /// 제출 요청
    func submit(userAnswer: String? = nil, quizId: Int? = nil) {
        self.showSubmitAlertView = true
        self.startSubmitTask(userAnswer: userAnswer, quizId: quizId)
    }
    
    /// 제출 작업 시작
    private func startSubmitTask(userAnswer: String?, quizId: Int?) {
        if submitTask == nil || submitTask?.isCancelled == true {
            submitTask = Task {
                switch selectedQuest.missionType {
                case .quiz:
                    if let userAnswer, let quizId {
                        await self.postChallengeWithQuiz(userAnswer: userAnswer, quizId: quizId)
                    }
                case .photo:
                    await self.postChallengeWithImage()
                }
            }
        }
    }
    
    /// 제출 작업 취소  & 상태 변경
    func cancelSubmitTask() {
        submitTask?.cancel()
        submitTask = nil
        submitStatus = .fail
    }
    
    /// scenePhase 변경 시 호출. 활성화 상태로 변한게 아니면 작업 취소
    func handleScenePhaseChange(to newPhase: ScenePhase) {
        if newPhase != .active {
            cancelSubmitTask()
        }
    }
    
    func clearSelectedImage() {
        self.showSubmitAlertView = false
        self.selectedImage = nil
    }
    
    @MainActor
    func postChallengeWithImage() async {
        submitStatus = .inProgress
        
        let isSuccess = await submitService.execute(missionId: selectedQuest.missionId, image: selectedImage)
        
        if isSuccess {
            AnalyticsService.logEvent(.questSubmitClick(questId: selectedQuest.id, questType: selectedQuest.questType?.rawValue.uppercased() ?? ""))
            submitStatus = .complete
        } else {
            submitStatus = .fail
        }
    }
    
    @MainActor
    func postChallengeWithQuiz(userAnswer: String, quizId: Int) async {
        let response = await challengeNetwork.postQuizChallenge(missionId: selectedQuest.missionId, quizId: quizId, answer: userAnswer)
        
        switch response {
        case .success:
            AnalyticsService.logEvent(.questSubmitClick(questId: selectedQuest.id, questType: selectedQuest.questType?.rawValue.uppercased() ?? ""))
            submitStatus = .complete
        case .failure:
            submitStatus = .fail
        }
    }
}
