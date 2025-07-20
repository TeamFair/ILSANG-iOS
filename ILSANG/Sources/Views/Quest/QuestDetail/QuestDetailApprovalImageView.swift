//
//  QuestDetailApprovalImageView.swift
//  ILSANG
//
//  Created by Lee Jinhee on 4/4/25.
//

import SwiftUI

struct QuestDetailApprovalImageView: View {
    let images: [UIImage]
    let showCount: Int
    let imageWidth: CGFloat
    let imageSpacing: CGFloat
    let isLoading: Bool
    let onTap: () -> ()
    
    var body: some View {
        return VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: imageSpacing) {
                QuestDetailTitleView(title: "퀘스트 인증 예시")
                Spacer(minLength: 0)
                if showCount >= 3 {
                    Text("예시 사진은 실제 유저들의 사진입니다")
                        .foregroundStyle(.gray300)
                        .styledFont(.badge1)
                }
            }
            
            if images.count == 0 {
                HStack(spacing: imageSpacing) {
                    ForEach(0..<showCount, id: \.self) { image in
                        Text(isLoading ? "" : "아직 퀘스트를\n수행하지 않았어요!")
                            .foregroundStyle(.gray300)
                            .styledFont(.badge2)
                            .multilineTextAlignment(.center)
                            .frame(width: imageWidth, height: imageWidth)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                            )
                            .opacity(isLoading ? 0 : 1)
                    }
                    .foregroundStyle(.gray100)
                }
            } else {
                HStack(spacing: imageSpacing) {
                    ForEach(0..<showCount, id: \.self) { idx in
                        if idx < images.count {
                            Image(uiImage: images[idx])
                                .resizable()
                                .scaledToFill()
                                .frame(width: imageWidth, height: imageWidth)
                                .clipShape(.rect(cornerRadius: 12))
                                .onTapGesture {
                                    onTap()
                                }
                        }
                    }
                }
            }
        }
        .animation(.smooth, value: images)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
