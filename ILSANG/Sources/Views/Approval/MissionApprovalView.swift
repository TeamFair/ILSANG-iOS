//
//  MissionApprovalView.swift
//  ILSANG
//
//  Created by Lee Jinhee on 7/20/25.
//

import SwiftUI

struct MissionApprovalView: View {
    @EnvironmentObject var dependencies: AppDependencies
    
    let missionId: Int
    let quest: QuestItem
    @Environment(\.dismiss) var dismiss
    
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
                    // FIXME: 퀘스트 라우터 연결
                }
            )
            
            ApprovalView(
                approvalSource: .detail(missionId: missionId, quest: quest),
                emojiNetwork: dependencies.emojiNetwork,
                missionHistoryRepository: dependencies.missionHistoryRepository,
                areaNameService: dependencies.areaNameService
            )
        }
        .background(Color.background)
        .navigationBarBackButtonHidden()
    }
}
