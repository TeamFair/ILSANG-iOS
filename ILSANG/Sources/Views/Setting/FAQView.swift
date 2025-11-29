//
//  FAQView.swift
//  ILSANG
//
//  Created by Lee Jinhee on 4/15/25.
//

import SwiftUI

struct FAQView: View {
    @Environment(\.layout) var layout
    @State private var expandedItem: String? = nil
    let faqList: [FAQItem] = FAQItem.faqList
    
    var body: some View {
        StandardScreenView(title: "자주 물어보는 질문") {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(faqList, id: \.question) { faq in
                        SettingToggleItemView(
                            title: faq.question,
                            isExpanded: expandedItem == faq.question,
                            toggleExpansion: {
                                withAnimation {
                                    expandedItem = (expandedItem == faq.question) ? nil : faq.question
                                }
                            }) {
                                Text(faq.answer.forceCharWrapping)
                                    .styledFont(.regular, size: 14, lineHeight: 20)
                                    .multilineTextAlignment(.leading)
                                    .foregroundStyle(.gray500)
                                    .padding(.vertical, 20)
                                    .padding(.horizontal, layout.horizontalPadding)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                    }
                }
            }
        }
    }
}

#Preview {
    FAQView()
}


struct FAQItem: Identifiable {
    let id = UUID()
    let question: String
    let answer: String
    
    static let faqList: [FAQItem] = [
        FAQItem(
            question: "일상 앱은 어떤 서비스인가요?",
            answer: "일상은 소상공인이 직접 만든 퀘스트를 수행하면서 보상을 받을 수 있는 고객 참여형 퀘스트 플랫폼입니다.\n카페, 식당, 서점, 체험 공간 등 다양한 장소에서 특별한 미션을 수행하고, 할인 혜택이나 포인트, 특별한 경험을 얻을 수 있어요!"
        ),
        FAQItem(
            question: "퀘스트는 어떻게 참여하나요?",
            answer: "1. 앱에서 원하는 퀘스트를 선택해요.\n2. 퀘스트 조건을 확인한 후, 해당 장소에 방문하거나 미션을 수행해요.\n3. 인증 방식(사진, 문제풀기 등)에 따라 완료하고 보상을 받아요!"
        ),
        FAQItem(
            question: "퀘스트 참여는 무료인가요?",
            answer: "대부분의 퀘스트는 무료로 참여할 수 있지만, 일부 퀘스트는 특정 제품을 구매해야 하거나 추가적인 비용이 발생할 수 있어요. 퀘스트 상세 페이지에서 조건을 꼭 확인하세요!"
        ),
        FAQItem(
            question: "퀘스트 보상은 어떻게 지급되나요?",
            answer: "퀘스트를 완료하면 보상이 자동 지급됩니다.\n보상은 경험치, 쿠폰, 할인 혜택, 스탬프 적립, 특별한 경험 등으로 다양하게 제공돼요."
        ),
        FAQItem(
            question: "퀘스트 완료 인증은 어떻게 하나요?",
            answer: """
            퀘스트마다 인증 방식이 달라요.
            • 사진 인증: 퀘스트에 맞게 사진을 찍어 업로드
            • O/X퀴즈 인증: 올바른 답변을 맞춰 퀘스트 수행
            • 서술형 문제 인증: 올바른 답변을 맞춰 퀘스트 수행
            """
        ),
        FAQItem(
            question: "보상을 못 받았어요. 어떻게 하나요?",
            answer: """
            퀘스트 완료 후 보상이 지급되지 않았다면, 다음을 확인해주세요!
            ✔ 인증 절차를 정확히 완료했나요?
            ✔ 보상 지급 시간이 걸릴 수 있어요. (최대 24시간)
            ✔ 그래도 보상이 안 들어오면, 앱 내 고객센터로 문의해주세요.
            """
        ),
        FAQItem(
            question: "퀘스트 참여 제한이 있나요?",
            answer: "일부 퀘스트는 특정 지역 또는 특정 시간대에만 참여할 수 있어요. 또한, 동일한 퀘스트를 여러 번 수행할 수 없는 경우도 있습니다."
        ),
        FAQItem(
            question: "제가 수행한 퀘스트 내역이 사라졌어요",
            answer: """
            일상 앱에서는 AI 검토 시스템을 통해 퀘스트 인증이 부적절한 경우 자동 삭제될 수 있습니다.
            • 퀘스트 조건에 맞지 않는 인증이 올라온 경우
            • 다른 사용자에게 불쾌감을 줄 수 있는 콘텐츠를 포함한 경우

            위와 같은 사유로 인증이 삭제될 수 있으며, 별도의 고지 없이 진행될 수 있으니 유의해주세요.
            만약 이와 무관하게 퀘스트 내역이 사라졌다면, 고객센터로 문의해 주시면 신속히 확인해드리겠습니다!
            """
        )
    ]

}
