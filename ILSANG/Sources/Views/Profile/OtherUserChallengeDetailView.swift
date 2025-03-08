//
//  OtherUserChallengeDetailView.swift
//  ILSANG
//
//  Created by Lee Jinhee on 3/8/25.
//

import SwiftUI

struct OtherUserChallengeDetailView: View {
    @Environment(\.dismiss) var dismiss
    let challenge: ChallengeViewModelItem
    
    var body: some View {
        VStack {
            NavigationTitleView(title: "챌린지 정보", isSeparatorHidden: false) {
                dismiss()
            }
            .padding(.bottom, 8) // 세로로 긴 이미지 대응 (NavigationTitleView의 bottom 패딩과 겹침)
            
            ChallengeImageView(missionImage: challenge.challengeImage ?? .logo, challengeData: challenge)
        }
        .navigationBarBackButtonHidden()
    }
}
