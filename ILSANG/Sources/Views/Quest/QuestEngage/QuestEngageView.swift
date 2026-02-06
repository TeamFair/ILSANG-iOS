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
    @Environment(\.layout) var layout
    
    init(
        quest: QuestItem,
        selectedImage: UIImage?,
        selectedQuest: QuestItem,
        challengeNetwork: ChallengeNetwork,
        submitService: ImageChallengeSubmitService
    ) {
        _vm = StateObject(
            wrappedValue: QuestEngageViewModel(
                quest: quest,
                challengeNetwork: challengeNetwork
            )
        )
        _submitVM = StateObject(
            wrappedValue: SubmitRouterViewModel(
                selectedImage: selectedImage,
                selectedQuest: selectedQuest,
                submitService: submitService,
                challengeNetwork: challengeNetwork
            )
        )
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
                .padding(.bottom, layout.bottomSpacing)
            }
            .padding(.top, 8)
            .padding(.horizontal, layout.horizontalPadding)
            .scrollIndicators(.never)
            .scrollDismissesKeyboard(.immediately)
            .onTapGesture {
                hideKeyboard()
            }
            .safeAreaInset(edge: .bottom) {
                PrimaryButton(
                    title: "퀘스트 인증하기",
                    buttonAble: vm.isSubmitAbled) {
                        DispatchQueue.main.asyncAfter(deadline: .now()+0.8) {
                            submitVM.submit(userAnswer: vm.selectedAnswer, quizId: vm.quiz?.quizId)
                        }
                    }
                    .padding(.bottom, layout.buttonBottomPadding)
                    .padding(.horizontal, layout.horizontalPadding)
                    .frame(alignment: .top)
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
        quest: .mockData,
        selectedImage: nil,
        selectedQuest: .mockData,
        challengeNetwork: ChallengeNetwork(),
        submitService: ImageChallengeSubmitService(
            imageNetwork: ImageNetwork(),
            challengeNetwork: ChallengeNetwork()
        )
    )
    // QuestEngageView(vm: QuestEngageViewModel(quest: .mockRepeatData, questNetwork: QuestNetwork()))
    // QuestEngageView(vm: QuestEngageViewModel(quest: .mockQuestList[3], questNetwork: QuestNetwork()))
}

