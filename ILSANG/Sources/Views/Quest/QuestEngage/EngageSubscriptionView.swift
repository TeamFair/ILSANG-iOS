//
//  EngageSubscriptionView.swift
//  ILSANG
//
//  Created by Lee Jinhee on 2/13/25.
//

import SwiftUI

struct EngageSubscriptionView: View {
    let type: QuizType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(type == .ox ? "OX 퀘스트 인증 참여 방법" : "서술형 퀘스트 인증 참여 방법")
                .styledFont(.heading1)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(alignment: .leading, spacing: 8) {
                EngageSubscriptionItemView(number: 1, text: type == .ox ? "내용을 읽고, O/X 중 정답을 선택해 주세요." : "내용을 읽고, 정답을 입력해 주세요.")
                EngageSubscriptionItemView(number: 2, text: "‘퀘스트 인증하기' 버튼을 눌러 인증을 해 주세요.")
                EngageSubscriptionItemView(number: 3, text: "정답일 경우 보상을 받을 수 있어요.")
            }
            .padding(.leading, 8)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 16)
        .padding(.trailing, 8)
        .padding(.vertical, 20)
        .foregroundStyle(.black)
        .roundedBackground(cornerRadius: 12)
    }
}

struct EngageSubscriptionItemView: View {
    let number: Int
    let text: String
    
    var body: some View {
        HStack(spacing: 4) {
            Text("\(number)")
                .foregroundStyle(.white)
                .styledFont(.caption1)
                .frame(width: 19, height: 19)
                .background(
                    Circle()
                        .fill(Color.primaryPurple)
                )
            
            Text(text.forceCharWrapping)
                .styledFont(.subTitle2)
                .foregroundStyle(.black)
        }
    }
}

#Preview {
    EngageSubscriptionView(type: .ox)
}
