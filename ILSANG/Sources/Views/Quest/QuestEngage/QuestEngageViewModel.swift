//
//  QuestEngageViewModel.swift
//  ILSANG
//
//  Created by Lee Jinhee on 2/9/25.
//

import Foundation

class QuestEngageViewModel: ObservableObject {
    // MARK: - Properties
    let quest: QuestViewModelItem
    private let questNetwork: QuestNetwork
    
    @Published var selectedAnswer: String = ""
    @Published var showBtn: Bool = true
    @Published var isKeyboardVisible: Bool = false
    
    // MARK: - Computed Properties
    var isOXType: Bool { quest.isRepeatQuest }
    var isSubmitAbled: Bool { selectedAnswer != "" }
    
    // MARK: - Initializer
    init(quest: QuestViewModelItem, questNetwork: QuestNetwork) {
        self.quest = quest
        self.questNetwork = questNetwork
    }
    
    // MARK: - Methods
    func submitAnswer(userAnswer: String) {
        print("Submitting answer: \(userAnswer)")
        // TODO: 제출 로직 추가
    }
}
