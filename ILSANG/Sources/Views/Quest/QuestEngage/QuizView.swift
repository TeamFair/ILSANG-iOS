//
//  QuizView.swift
//  ILSANG
//
//  Created by Lee Jinhee on 2/13/25.
//

import SwiftUI

struct QuizView: View, KeyboardReadable {
    let missionType: MissionType
    let quiz: QuizResponse
    @Binding var selectedAnswer: String
    @Binding var isKeyboardVisible: Bool
    
    var body: some View {
        if case let .quiz(quizType) = missionType {
            switch quizType {
            case .text:
                textQuizView(question: quiz.question, hint: quiz.hint, userAnswer: selectedAnswer)
            case .ox:
                oxQuizView(question: quiz.question, selection: selectedAnswer)
            }
        }
    }
    
    private func oxQuizView(question: String, selection: String) -> some View {
        VStack(alignment: .leading, spacing: 24) {
            QuizQuestionView(question: question)
            
            HStack(spacing: 10) {
                Button {
                    selectedAnswer = "O"
                } label: {
                    OXSelectionLabel(label: "O", isSelected: selectedAnswer == "O")
                }
                
                Button {
                    selectedAnswer = "X"
                } label: {
                    OXSelectionLabel(label: "X", isSelected: selectedAnswer == "X")
                }
            }
        }
        .padding(.vertical, 24)
        .padding(.horizontal, 20)
        .roundedBackground(cornerRadius: 12)
    }
    
    private func textQuizView(question: String, hint: String?, userAnswer: String) -> some View {
        VStack(alignment: .leading, spacing: 24) {
            QuizQuestionView(question: question)
            
            if let hint {
                VStack(alignment: .leading, spacing: 4) {
                    Text("힌트")
                        .styledFont(.heading2)
                        .foregroundStyle(.primaryPurple)
                    Text(hint)
                        .styledFont(.subTitle2)
                        .foregroundStyle(.gray300)
                }
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
}

/// OX 선택 상태를 정적으로 표시하는 라벨
struct OXSelectionLabel: View {
    let label: String
    let isSelected: Bool
    
    var body: some View {
        Text(label)
            .styledFont(.title1)
            .frame(maxWidth: .infinity)
            .frame(height: 65)
            .foregroundStyle(isSelected ? .white : .black)
            .roundedBackground(
                cornerRadius: 12,
                bgColor: isSelected ? .primaryPurple : .gray100
            )
    }
}

struct QuizQuestionView: View {
    let question: String
    
    var body: some View {
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
        QuizView(missionType: .quiz(.ox), quiz: QuizResponse(quizId: 1, question: "질문", hint: "힌트"), selectedAnswer: .constant("answer"), isKeyboardVisible: .constant(true))
        QuizView(missionType: .quiz(.text), quiz: QuizResponse(quizId: 1, question: "질문", hint: "힌트"), selectedAnswer: .constant("answer"), isKeyboardVisible: .constant(true))
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
