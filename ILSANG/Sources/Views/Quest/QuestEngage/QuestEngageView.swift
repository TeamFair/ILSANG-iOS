//
//  QuestEngageView.swift
//  ILSANG
//
//  Created by Lee Jinhee on 2/9/25.
//

import SwiftUI

struct QuestEngageView: View {
    @StateObject var vm: QuestEngageViewModel
    
    @EnvironmentObject var sharedState: SharedState
    @Environment(\.dismiss) var dismiss
    
    init(vm: QuestEngageViewModel) {
        _vm = StateObject(wrappedValue: vm)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            NavigationTitleView(title: "퀘스트 참여", isSeparatorHidden: true, background: .background) {
                dismiss()
            }
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // 퀘스트 정보
                    QuestInfoView(quest: vm.quest)
                    
                    // 인증 참여 방법 설명
                    EngageSubscriptionView(type: vm.quest.quizType)
                    
                    // 퀴즈 영역
                    QuizView(quest: vm.quest, selectedAnswer: $vm.selectedAnswer, isKeyboardVisible: $vm.isKeyboardVisible)
                }
                .padding(.top, 30)
                .padding(.bottom ,72)
            }
            .padding(.top, 8)
            .padding(.horizontal, 20)
            .scrollIndicators(.never)
            .scrollDismissesKeyboard(.immediately)
            .onTapGesture {
                hideKeyboard()
            }
            .safeAreaInset(edge: .bottom) {
                PrimaryButton(
                    title: "퀘스트 인증하기",
                    buttonAble: vm.isSubmitAbled) {
                        vm.submitAnswer(userAnswer: vm.selectedAnswer)
                    }
                    .padding(.top, 15)
                    .padding(.horizontal, 20)
                    .frame(alignment: .top)
                    .background(Color.background)
                    .opacity(vm.isKeyboardVisible ? 0 : 1)
            }
        }
        .background(Color.background)
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    QuestEngageView(vm: QuestEngageViewModel(quest: .mockData, questNetwork: QuestNetwork()))
    // QuestEngageView(vm: QuestEngageViewModel(quest: .mockRepeatData, questNetwork: QuestNetwork()))
    // QuestEngageView(vm: QuestEngageViewModel(quest: .mockQuestList[3], questNetwork: QuestNetwork()))
}

