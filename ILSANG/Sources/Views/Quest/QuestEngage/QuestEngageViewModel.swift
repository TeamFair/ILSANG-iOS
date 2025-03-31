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
    let quest: QuestViewModelItem
    private let quizNetwork: QuizNetwork
    
    @Published var quiz: Quiz?
    @Published var selectedAnswer: String = ""
    @Published var showBtn: Bool = true
    @Published var isKeyboardVisible: Bool = false
    
    // MARK: - Computed Properties
    var isOXType: Bool { quest.missionType == .quiz(.ox) }
    var isSubmitAbled: Bool { selectedAnswer != "" }
    
    // MARK: - Initializer
    init(quest: QuestViewModelItem, quizNetwork: QuizNetwork) {
        self.quest = quest
        self.quizNetwork = quizNetwork
       
    }
    
    @MainActor
    func getRandomQuiz() async {
        quiz = try? await quizNetwork.getRandomQuiz(missionId: quest.missionId).get().data
    }
    
    // MARK: - Methods
    func compareAnswer(userAnswer: String) -> Bool {
        let answers = quiz?.answers.compactMap { $0.content } ?? []
        return answers.contains(userAnswer)
    }
}
