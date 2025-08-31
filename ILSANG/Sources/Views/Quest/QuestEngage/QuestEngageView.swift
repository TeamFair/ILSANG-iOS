//
//  QuestEngageView.swift
//  ILSANG
//
//  Created by Lee Jinhee on 2/9/25.
//

import SwiftUI

// TODO: 초기화 시점 알아보기(중복 초기화 방지)
struct QuestEngageView: View {
    @StateObject var vm: QuestEngageViewModel
    @StateObject var submitVM: SubmitRouterViewModel
    
    @EnvironmentObject var sharedState: SharedState
    @Environment(\.dismiss) var dismiss
    
    init(vm: QuestEngageViewModel, submitVM: SubmitRouterViewModel) {
        _vm = StateObject(wrappedValue: vm)
        _submitVM = StateObject(wrappedValue: submitVM)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            NavigationTitleView(title: "퀘스트 참여", isSeparatorHidden: true, background: .background) {
                dismiss()
            }
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // 퀘스트 정보
                    QuestEngageInfoView(quest: vm.quest)
                    
                    // 인증 참여 방법 설명
                    if case let .quiz(quizType) = vm.quest.missionType {
                        EngageSubscriptionView(type: quizType)
                    }
                    
                    // 퀴즈 영역
                    if let quiz = vm.quiz {
                        QuizView(missionType: vm.quest.missionType, quiz: quiz, selectedAnswer: $vm.selectedAnswer, isKeyboardVisible: $vm.isKeyboardVisible)
                    }
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
                        submitVM.showSubmitAlertView = true
                        submitVM.submitStatus = .inProgress
                        DispatchQueue.main.asyncAfter(deadline: .now()+0.8) {
                            submitVM.submit(userAnswer: vm.selectedAnswer, quizId: vm.quiz?.quizId)
                        }
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
        .overlay {
            SubmitAlertView(vm: submitVM)
        }
        .task {
            await vm.getRandomQuiz()
        }
    }
}

#Preview {
    QuestEngageView(
        vm: QuestEngageViewModel(quest: .mockData, challengeNetwork: ChallengeNetwork()),
        submitVM: SubmitRouterViewModel(
            selectedImage: nil,
            selectedQuest: .mockData,
            submitService: ImageChallengeSubmitService(
                imageNetwork: ImageNetwork(),
                challengeNetwork: ChallengeNetwork()
            ), challengeNetwork: ChallengeNetwork()
        )
    )
    // QuestEngageView(vm: QuestEngageViewModel(quest: .mockRepeatData, questNetwork: QuestNetwork()))
    // QuestEngageView(vm: QuestEngageViewModel(quest: .mockQuestList[3], questNetwork: QuestNetwork()))
}

