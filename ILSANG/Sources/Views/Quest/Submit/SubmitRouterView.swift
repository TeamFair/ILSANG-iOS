//
//  SubmitRouterView.swift
//  ILSANG
//
//  Created by Lee Jinhee on 5/29/24.
//

import SwiftUI
import Photos

struct SubmitRouterView: View {
    @StateObject var vm: SubmitRouterViewModel
    @Environment(\.dismiss) var dismiss

    init(selectedQuest: QuestViewModelItem) {
        _vm = StateObject(wrappedValue: SubmitRouterViewModel(selectedQuest: selectedQuest))
    }

    var body: some View {
        Group {
            if let myImage = vm.selectedImage {
                VStack(spacing: 0) {
                    NavigationTitleView(title: "퀘스트 인증") {
                        vm.clearSelectedImage()
                    }
                    .padding(.bottom, 8) // 세로로 긴 이미지 대응 (NavigationTitleView의 bottom 패딩과 겹침)
                    
                    Image(uiImage: myImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.bottom, 90)
                }
                .overlay(alignment: .bottom) {
                    buttonView
                }
                .ignoresSafeArea(edges: .bottom)
            } else {
                CameraView(submitViewModel: vm)
            }
        }
        .background(Color.white)
        .overlay {
            SubmitAlertView(selectedImage: vm.selectedImage, selectedQuest: vm.selectedQuest, showSubmitAlertView: vm.showSubmitAlertView)
        }
    }
}

extension SubmitRouterView {
    private var buttonView: some View {
        HStack(spacing: 12) {
            Button {
                vm.clearSelectedImage()
            } label: {
                Text("다시찍기")
            }
            .frame(height: 50)
            .frame(maxWidth: .infinity)
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(.primaryPurple)
            .background(Color.primary100)
            .cornerRadius(12)
            
            PrimaryButton(title: "제출하기") {
                vm.submit()
            }
        }
        .padding([.bottom,.horizontal], 20)
        .frame(height: 110)
        .background(Color.white)
        .cornerRadius(24, corners: [.topLeft, .topRight])
    }
}

#Preview {
    SubmitRouterView(selectedQuest: .mockData)
}
