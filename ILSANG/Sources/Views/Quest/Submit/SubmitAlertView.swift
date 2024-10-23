//
//  SubmitAlertView.swift
//  ILSANG
//
//  Created by Lee Jinhee on 5/25/24.
//

import SwiftUI

struct SubmitAlertView: View {
    @ObservedObject var vm: SubmitAlertViewModel
    @Environment(\.dismiss) var dismiss
    
    init(selectedImage: UIImage?, selectedQuest: QuestViewModelItem, showSubmitAlertView: Bool) {
        _vm = ObservedObject(wrappedValue: SubmitAlertViewModel(selectedImage: selectedImage, selectedQuest: selectedQuest, imageNetwork: ImageNetwork(), challengeNetwork: ChallengeNetwork(), showSubmitAlertView: showSubmitAlertView)
        )
    }
    
    var body: some View {
        ZStack {
            if vm.showSubmitAlertView {
                Color.black.opacity(0.7).ignoresSafeArea()
                
                submitAlertView
                    .task { await vm.postChallengeWithImage() }
            }
        }
        .onDisappear {
            vm.showSubmitAlertView = false
        }
    }
    
    @ViewBuilder
    private var submitAlertView: some View {
        switch vm.submitStatus {
        case .submit, .fail:
            SubmitStatusView(status: vm.submitStatus) {
                vm.showSubmitAlertView = false
            }
        case .complete:
            SubmitCompleteView(quest: vm.selectedQuest) {
                vm.showSubmitAlertView = false
                dismiss()
            }
        }
    }
}

#Preview {
    SubmitAlertView(selectedImage: .img0, selectedQuest: .mockData, showSubmitAlertView: true)
}
