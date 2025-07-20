//
//  ApprovalDetailView.swift
//  ILSANG
//
//  Created by Lee Jinhee on 7/20/25.
//

import SwiftUI

struct ApprovalDetailView: View {
    let questId: String
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            NavigationTitleView(title: "퀘스트 인증 예시", isSeparatorHidden: true, background: .background) {
                dismiss()
            }
            .padding(.bottom, 8)

            ApprovalView(
                viewModel: .init(
                    approvalSource: .detail(questId: questId),
                    emojiNetwork: EmojiNetwork(),
                    challengeNetwork: ChallengeNetwork()
                )
            )
        }
        .navigationBarBackButtonHidden()
    }
}
