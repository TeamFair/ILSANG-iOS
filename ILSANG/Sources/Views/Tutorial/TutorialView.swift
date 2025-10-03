//
//  TutorialView.swift
//  ILSANG
//
//  Created by Lee Jinhee on 1/5/25.
//

import SwiftUI

struct TutorialView: View {
    @StateObject var viewModel: TutorialViewModel = TutorialViewModel(content: [
        TutorialContent(
            id: 0,
            title: "원하는 퀘스트를 선택하세요",
            image: .tutorialStep1
        ),
        TutorialContent(
            id: 1,
            title: "사진을 촬영해주세요",
            image: .tutorialStep2
        ),
        TutorialContent(
            id: 2,
            title: "사진을 찍으면 퀘스트 완료!",
            image: .tutorialStep3
        )
    ])
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // 스킵 버튼
            skipButton
            
            Spacer(minLength: 16)
                .frame(maxHeight: 48)
            
            // 스텝, 타이틀, 이미지 콘텐츠
            TabView(selection: $viewModel.step) {
                ForEach(viewModel.content, id: \.id) { content in
                    TutorialContentView(
                        step: content.id,
                        title: content.title,
                        image: content.image
                    )
                    .tag(content.id)
                }
            }
            .animation(.easeInOut, value: viewModel.step)
            .tabViewStyle(.page(indexDisplayMode: .never))
            .padding(.horizontal, -LayoutConstants.horizontalPadding)
            
            // 인디케이터
            paginationIndicator
            
            Spacer(minLength: 0)
            
            // 버튼 영역
            actionButtons
        }
        .padding(.horizontal, LayoutConstants.horizontalPadding)
        .background(Color.background)
        .onChange(of: viewModel.finish) { oldValue, newValue in
            if newValue { dismiss() }
        }
    }
    
    private var skipButton: some View {
        Button {
            dismiss()
        } label: {
            HStack(spacing: 0) {
                Text("SKIP")
                    .styledFont(.tabBold)
                Image(.arrowRight)
                    .renderingMode(.template)
                    .frame(width: 18, height: 18)
            }
            .foregroundStyle(.gray300)
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
        .padding(.top, 16)
    }
    
    private var paginationIndicator: some View {
        HStack(spacing: LayoutConstants.indicatorSpacing) {
            let pageCount = viewModel.contentCount
            if pageCount >= 2 {
                ForEach(0..<pageCount, id: \.self) { index in
                    Circle()
                        .frame(width: LayoutConstants.circleSize, height: LayoutConstants.circleSize)
                        .foregroundStyle(index == viewModel.step ? Color.gray500 : Color.gray100)
                        .animation(.easeInOut, value: index)
                }
            }
        }
        .padding(.bottom, 43)
    }
    
    // 기본 애니메이션이 부자연스럽게 적용되어, 분기 처리로 구현
    @ViewBuilder
    private var actionButtons: some View {
        if !viewModel.isLast && !viewModel.isFirst {
            HStack(spacing: 8) {
                SecondaryButton(title: "이전") {
                    viewModel.performSecondaryAction()
                }
                
                PrimaryButton(title: viewModel.isLast ? "완료" : "다음") {
                    viewModel.performPrimaryAction()
                }
            }
        } else {
            PrimaryButton(title: viewModel.isLast ? "완료" : "다음") {
                viewModel.performPrimaryAction()
            }
        }
    }
    
    private struct LayoutConstants {
        static let horizontalPadding: CGFloat = 20
        static let indicatorSpacing: CGFloat = 4
        static let circleSize: CGFloat = 10
    }
}

struct TutorialContentView: View {
    let step: Int
    let title: String
    let image: UIImage
    
    var body: some View {
        VStack(spacing: 0) {
            Text("Step 0\(step+1)")
                .foregroundStyle(.white)
                .styledFont(.tabBold)
                .frame(width: 70, height: 25)
                .roundedBackground(cornerRadius: 12, bgColor: .primary300)
                .padding(.bottom, 16)
            
            Text(title)
                .styledFont(.title1)
                .foregroundStyle(.black)
                .padding(.bottom, 33)
            
            Spacer(minLength: 0)
            
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(width: .screenWidth - 120)
                .padding(.bottom, 4)
            
            Spacer(minLength: 32)
        }
    }
}

#Preview {
    TutorialView()
}
