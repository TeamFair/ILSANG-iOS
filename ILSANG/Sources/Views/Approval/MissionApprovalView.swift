//
//  MissionApprovalView.swift
//  ILSANG
//
//  Created by Lee Jinhee on 7/20/25.
//

import Combine
import SwiftUI

struct MissionApprovalView: View {
    @EnvironmentObject var dependencies: AppDependencies
    @Environment(\.dismiss) var dismiss

    private let questSubmissionNotifier: QuestSubmissionNotifier

    let missionId: Int
    let quest: QuestItem
    let showQuestApproval: () -> Void
    
    private var cancellables = Set<AnyCancellable>()

    init(missionId: Int, quest: QuestItem, questSubmissionNotifier: QuestSubmissionNotifier, showQuestApproval: @escaping () -> Void) {
        self.missionId = missionId
        self.quest = quest
        self.showQuestApproval = showQuestApproval
        self.questSubmissionNotifier = questSubmissionNotifier
        
        // 퀘스트 수행 후 재수행 불가능하도록 퀘스트 수행시 수행시간 업데이트
        questSubmissionNotifier.$refreshTrigger
            .removeDuplicates()
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { _ in
                Log("MissionApprovalView: 퀘스트 제출 트리거 > 마지막 수행시간 업데이트")
                quest.lastCompleteDate = .now
            }
            .store(in: &cancellables)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            NavigationTitleView(title: "퀘스트 인증 예시", isSeparatorHidden: true) {
                dismiss()
            }
            .padding(.bottom, 8)
            
            ApprovalQuestView(
                questType: quest.questType ?? .normal,
                repeatType: quest.repeatType,
                questTitle: quest.title,
                writerName: quest.writer,
                bgStyle: .verticalStroke,
                status: quest.questStatus, 
                action: {
                    showQuestApproval()
                }
            )
            
            ApprovalView(
                approvalSource: .detail(missionId: missionId, quest: quest),
                emojiNetwork: dependencies.emojiNetwork,
                questRepository: dependencies.questRepository,
                missionHistoryRepository: dependencies.missionHistoryRepository,
                favoriteService: dependencies.favoriteService,
                areaNameService: dependencies.areaNameService,
                illsangZoneManager: dependencies.illsangZoneManager,
                questSubmissionNotifier: dependencies.questSubmissionNotifier
            )
        }
        .background(Color.background)
        .navigationBarBackButtonHidden()
    }
}
