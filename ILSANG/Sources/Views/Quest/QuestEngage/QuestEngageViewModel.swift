//
//  QuestEngageViewModel.swift
//  ILSANG
//
//  Created by Lee Jinhee on 2/9/25.
//

import Foundation

/// 퀴즈 데이터를 관리하고 정답을 선택하는 역할
class QuestEngageViewModel: ObservableObject {
    // MARK: - Properties
    let quest: QuestItem
    private let challengeNetwork: ChallengeNetwork
    
    @Published var quiz: QuizResponse?
    @Published var selectedAnswer: String = ""
    @Published var showBtn: Bool = true
    @Published var isKeyboardVisible: Bool = false
    
    // MARK: - Computed Properties
    var isOXType: Bool { quest.missionType == .quiz(.ox) }
    var isSubmitAbled: Bool { selectedAnswer != "" }
    
    // MARK: - Initializer
    init(quest: QuestItem, challengeNetwork: ChallengeNetwork) {
        self.quest = quest
        self.challengeNetwork = challengeNetwork
        Log("🏃🏻‍♂️ QuestEngageViewModel: init")
    }
    
    deinit {
        Log("🏃🏻‍♂️ QuestEngageViewModel: deinit")
    }
    
    @MainActor
    func getRandomQuiz() async {
        quiz = try? await challengeNetwork.getRandomQuiz(missionId: quest.missionId)
            .get()
    }
}
