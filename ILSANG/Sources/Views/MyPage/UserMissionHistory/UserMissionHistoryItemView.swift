//
//  ChallengeListItemView.swift
//  ILSANG
//
//  Created by Lee Jinhee on 3/8/25.
//

import SwiftUI

struct UserMissionHistoryItemView: View {
    let challenge: UserMissionHistoryViewModelItem
    
    var body: some View {
        ZStack {
            Group {
                if let image = challenge.submitImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    Image(uiImage: .logoWithAlpha)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100)
                }
            }
            .scaledToFill()
            .frame(height: 172)
            .frame(maxWidth: .infinity)
            .overlay(alignment: .bottom) {
                Rectangle()
                    .frame(height: 85)
                    .foregroundStyle(
                        .linearGradient(
                            colors: [.clear, .black.opacity(0.8)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .opacity(challenge.submitImage == nil ? 0.3 : 1)
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            VStack(alignment: .leading, spacing: 6) {
                Spacer()
                Text(challenge.title)
                    .font(.system(size: 23, weight: .bold))
                    .foregroundColor(.white)
                
                Text(challenge.createdAt.timeAgoCreatedAt())
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.gray200)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
        }
    }
}
