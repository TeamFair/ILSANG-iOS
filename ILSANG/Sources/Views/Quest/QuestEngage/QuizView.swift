//
//  QuizView.swift
//  ILSANG
//
//  Created by Lee Jinhee on 2/13/25.
//

import SwiftUI


struct QuizView: View, KeyboardReadable {
    let quest: QuestViewModelItem
    @Binding var selectedAnswer: String
    @Binding var isKeyboardVisible: Bool
    
    var body: some View {
        switch quest.quizType {
        case .text:
            textQuizView(question: quest.question, hint: quest.hint ?? "", userAnswer: selectedAnswer)
        case .ox:
            oxQuizView(question: quest.question, selection: selectedAnswer)
        }
    }
    
    private func oxQuizView(question: String, selection: String) -> some View {
        VStack(alignment: .leading, spacing: 24) {
            quizTitleView(question)
            
            HStack(spacing: 10) {
                Button {
                    selectedAnswer = "O"
                } label: {
                    Text("O")
                        .styledFont(.title1)
                        .frame(maxWidth: .infinity)
                        .frame(height: 65)
                        .foregroundStyle(selection == "O" ? .white : .black)
                        .roundedBackground(cornerRadius: 12, bgColor: selection == "O" ? .primaryPurple : .gray100)
                }
                
                Button {
                    selectedAnswer = "X"
                } label: {
                    Text("X")
                        .styledFont(.title1)
                        .frame(maxWidth: .infinity)
                        .frame(height: 65)
                        .foregroundStyle(selection == "X" ? .white : .black)
                        .roundedBackground(cornerRadius: 12, bgColor: selection == "X" ? .primaryPurple : .gray100)
                }
            }
        }
        .padding(.vertical, 24)
        .padding(.horizontal, 20)
        .roundedBackground(cornerRadius: 12)
    }
    
    private func textQuizView(question: String, hint: String, userAnswer: String) -> some View {
        VStack(alignment: .leading, spacing: 24) {
            quizTitleView(question)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("힌트")
                    .styledFont(.heading2)
                    .foregroundStyle(.primaryPurple)
                Text(hint)
                    .styledFont(.subTitle2)
                    .foregroundStyle(.gray300)
            }
            
            TextField("", text: $selectedAnswer, axis: .vertical)
                .onReceive(keyboardPublisher) { newIsKeyboardVisible in
                    isKeyboardVisible = newIsKeyboardVisible
                }
                .styledFont(.caption1)
                .submitLabel(.return)
                .keyboardType(.default)
                .foregroundStyle(.black)
                .overlay(alignment: .leading) {
                    if selectedAnswer.isEmpty {
                        Text("정답을 입력해주세요.")
                            .styledFont(.caption1)
                            .foregroundStyle(.gray300)
                            .padding(.leading, 2)
                            .allowsHitTesting(false)
                    }
                }
                .padding(.vertical, 15)
                .padding(.horizontal, 16)
                .frame(minHeight: 54)
                .frame(maxWidth: .infinity, alignment: .leading)
                .roundedBackground(cornerRadius: 12, bgColor: .gray100)
        }
        .padding(.vertical, 24)
        .padding(.horizontal, 20)
        .roundedBackground(cornerRadius: 12)
    }
    
    private func quizTitleView(_ question: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Text("Q")
                    .styledFont(.title1)
                    .foregroundStyle(.white)
                    .frame(width: 45, height: 45)
                    .background(
                        Circle()
                            .fill(.primaryPurple)
                    )
                Text("QUIZ")
                    .styledFont(.title1)
                    .foregroundStyle(.primaryPurple)
            }
            
            Text(question.forceCharWrapping)
                .styledFont(.subTitle2)
                .foregroundStyle(.black)
                .multilineTextAlignment(.leading)
        }
    }
}

#Preview {
    VStack {
        QuizView(quest: .mockData, selectedAnswer: .constant("answer"), isKeyboardVisible: .constant(true))
        QuizView(quest: .mockQuestList[1], selectedAnswer: .constant("answer"), isKeyboardVisible: .constant(true))
    }
    .padding()
    .background(Color.background)
}

// MARK: - 키보드
import Combine

protocol KeyboardReadable {
    var keyboardPublisher: AnyPublisher<Bool, Never> { get }
}

extension KeyboardReadable {
    var keyboardPublisher: AnyPublisher<Bool, Never> {
        Publishers.Merge(
            NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillShowNotification)
                .map { _ in true },
            
            NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillHideNotification)
                .map { _ in false }
        )
        .eraseToAnyPublisher()
    }
}
