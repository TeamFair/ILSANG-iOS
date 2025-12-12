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
            NavigationTitleView(title: "퀘스트 인증 예시", isSeparatorHidden: true, background: .background) {
                dismiss()
            }
            .padding(.bottom, 8)

            ApprovalView(
                approvalSource: .detail(missionId: missionId, quest: quest),
                emojiNetwork: dependencies.emojiNetwork,
                missionHistoryRepository: dependencies.missionHistoryRepository,
                areaNameService: dependencies.areaNameService
            )
        }
        .navigationBarBackButtonHidden()
    }
}
